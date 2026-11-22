package com.example.cool_ar.ar

import android.app.Activity
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.util.Log
import android.view.MotionEvent
import com.google.ar.core.*
import com.google.ar.core.exceptions.*
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

/**
 * Manages the ARCore session, rendering, plane detection, and cube placement.
 *
 * This class is NOT a singleton. Each [ArPlatformView] owns its own instance.
 * It implements [GLSurfaceView.Renderer] to handle the OpenGL draw loop.
 *
 * Responsibilities:
 * - Create and configure an ARCore [Session]
 * - Render the camera background
 * - Detect planes and report tracking state
 * - Handle tap → hit-test → anchor → draw cube
 */
class ArManager(
    private val activity: Activity,
    private val eventEmitter: ArEventEmitter,
) : GLSurfaceView.Renderer {

    companion object {
        private const val TAG = "ArManager"
    }

    private var session: Session? = null
    private var sessionConfigured = false
    @Volatile
    private var sessionResumed = false

    // Display rotation helper
    private var displayRotationHelper: DisplayRotationHelper? = null

    // Camera background renderer
    private var backgroundRenderer: BackgroundRenderer? = null

    // Placed cubes: anchor + color + size
    private val placedCubes = mutableListOf<PlacedCube>()

    // Pending cube config from Flutter (set by placeObject, consumed on next frame)
    @Volatile
    private var pendingCubeConfig: CubeConfig? = null

    // Queued tap for hit-test (set by touch handler)
    @Volatile
    private var queuedTap: MotionEvent? = null

    // Track previous tracking state to avoid spamming events
    private var lastTrackingState: TrackingState? = null

    // Simple cube renderer
    private var cubeRenderer: CubeRenderer? = null

    /**
     * Called by [ArPlatformView] when the view receives a touch event.
     */
    fun onTouch(event: MotionEvent) {
        if (event.action == MotionEvent.ACTION_UP) {
            queuedTap = event
        }
    }

    /**
     * Called by Flutter via MethodChannel to place a cube at the next tap hit-test.
     */
    fun placeObject(color: FloatArray, size: Float) {
        pendingCubeConfig = CubeConfig(color, size)
    }

    // ─── GLSurfaceView.Renderer ───────────────────────────────────────────

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0.1f, 0.1f, 0.1f, 1.0f)

        try {
            backgroundRenderer = BackgroundRenderer()
            cubeRenderer = CubeRenderer()

            val arSession = Session(activity)
            val arConfig = Config(arSession).apply {
                planeFindingMode = Config.PlaneFindingMode.HORIZONTAL
                updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                // Depth is not needed for Phase 1
                depthMode = Config.DepthMode.DISABLED
            }
            arSession.configure(arConfig)
            session = arSession
            sessionConfigured = true

            displayRotationHelper = DisplayRotationHelper(activity)
            displayRotationHelper?.onResume()

            // Resume immediately — the session starts paused and onDrawFrame
            // is already firing on this GL thread. Without this, every frame
            // throws SessionPausedException.
            arSession.resume()
            sessionResumed = true

            eventEmitter.emitSessionReady()
            Log.i(TAG, "ARCore session created and resumed successfully")
        } catch (e: UnavailableArcoreNotInstalledException) {
            eventEmitter.emitError("ARCore is not installed")
            Log.e(TAG, "ARCore not installed", e)
        } catch (e: UnavailableApkTooOldException) {
            eventEmitter.emitError("ARCore APK is too old, please update")
            Log.e(TAG, "ARCore APK too old", e)
        } catch (e: UnavailableSdkTooOldException) {
            eventEmitter.emitError("App SDK is too old for this ARCore version")
            Log.e(TAG, "SDK too old", e)
        } catch (e: UnavailableDeviceNotCompatibleException) {
            eventEmitter.emitError("This device does not support AR")
            Log.e(TAG, "Device not compatible", e)
        } catch (e: Exception) {
            eventEmitter.emitError("Failed to create AR session: ${e.message}")
            Log.e(TAG, "Session creation failed", e)
        }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        displayRotationHelper?.onSurfaceChanged(width, height)
        GLES20.glViewport(0, 0, width, height)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)

        val currentSession = session ?: return
        if (!sessionConfigured || !sessionResumed) return

        displayRotationHelper?.updateSessionIfNeeded(currentSession)

        try {
            currentSession.setCameraTextureName(backgroundRenderer!!.textureId)
            val frame = currentSession.update()
            val camera = frame.camera

            // Draw camera background
            backgroundRenderer?.draw(frame)

            // Report tracking state changes
            val currentTrackingState = camera.trackingState
            if (currentTrackingState != lastTrackingState) {
                lastTrackingState = currentTrackingState
                val stateStr = when (currentTrackingState) {
                    TrackingState.TRACKING -> "tracking"
                    TrackingState.PAUSED -> "paused"
                    TrackingState.STOPPED -> "stopped"
                }
                eventEmitter.emitTrackingStateChanged(stateStr)
            }

            // Only process taps when tracking
            if (camera.trackingState != TrackingState.TRACKING) return

            // Handle tap → hit-test → place cube
            handleTap(frame)

            // Get view and projection matrices
            val viewMatrix = FloatArray(16)
            val projectionMatrix = FloatArray(16)
            camera.getViewMatrix(viewMatrix, 0)
            camera.getProjectionMatrix(projectionMatrix, 0, 0.1f, 100.0f)

            // Draw all placed cubes
            GLES20.glEnable(GLES20.GL_DEPTH_TEST)
            for (cube in placedCubes) {
                if (cube.anchor.trackingState == TrackingState.TRACKING) {
                    val modelMatrix = FloatArray(16)
                    cube.anchor.pose.toMatrix(modelMatrix, 0)
                    cubeRenderer?.draw(modelMatrix, viewMatrix, projectionMatrix, cube.color, cube.size)
                }
            }

        } catch (e: CameraNotAvailableException) {
            eventEmitter.emitError("Camera not available: ${e.message}")
            Log.e(TAG, "Camera not available", e)
        } catch (e: Exception) {
            Log.e(TAG, "Error during frame update", e)
        }
    }

    private fun handleTap(frame: Frame) {
        val tap = queuedTap ?: return
        queuedTap = null

        val config = pendingCubeConfig ?: CubeConfig(
            floatArrayOf(0.3f, 0.7f, 0.3f, 1.0f), // default green
            0.1f
        )
        pendingCubeConfig = null

        // Hit test against detected planes
        val hitResults = frame.hitTest(tap)
        for (hit in hitResults) {
            val trackable = hit.trackable
            if (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose)) {
                val anchor = hit.createAnchor()
                placedCubes.add(PlacedCube(anchor, config.color, config.size))
                Log.i(TAG, "Cube placed at anchor. Total cubes: ${placedCubes.size}")
                break // Place only at the first valid hit
            }
        }
    }

    // ─── Lifecycle ─────────────────────────────────────────────────────────

    fun resume() {
        session?.let { s ->
            try {
                s.resume()
                sessionResumed = true
                displayRotationHelper?.onResume()
            } catch (e: CameraNotAvailableException) {
                eventEmitter.emitError("Camera not available on resume")
                Log.e(TAG, "Camera not available on resume", e)
            }
        }
    }

    fun pause() {
        sessionResumed = false
        displayRotationHelper?.onPause()
        session?.pause()
    }

    fun destroy() {
        // Clean up anchors
        for (cube in placedCubes) {
            cube.anchor.detach()
        }
        placedCubes.clear()
        session?.close()
        session = null
    }

    // ─── Inner types ──────────────────────────────────────────────────────

    private data class CubeConfig(val color: FloatArray, val size: Float)

    private data class PlacedCube(val anchor: Anchor, val color: FloatArray, val size: Float)
}
