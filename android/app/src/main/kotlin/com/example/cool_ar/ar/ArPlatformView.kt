package com.example.cool_ar.ar

import android.annotation.SuppressLint
import android.app.Activity
import android.opengl.GLSurfaceView
import android.view.MotionEvent
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView

/**
 * Flutter PlatformView that hosts a GLSurfaceView for ARCore rendering.
 *
 * Each instance owns its own [ArManager] and [ArMethodChannelHandler].
 * The GLSurfaceView is the "surface" that ARCore renders the camera and
 * 3D content onto.
 *
 * Touch events are forwarded to [ArManager] for hit-testing.
 */
class ArPlatformView(
    private val activity: Activity,
    messenger: BinaryMessenger,
    private val eventEmitter: ArEventEmitter,
) : PlatformView {

    private val glSurfaceView: GLSurfaceView
    private val arManager: ArManager
    private val methodChannelHandler: ArMethodChannelHandler

    init {
        arManager = ArManager(activity, eventEmitter)

        // Set up MethodChannel handler — it delegates calls to arManager
        methodChannelHandler = ArMethodChannelHandler(messenger, arManager)

        // Configure GLSurfaceView for ARCore
        glSurfaceView = GLSurfaceView(activity)
        glSurfaceView.preserveEGLContextOnPause = true
        glSurfaceView.setEGLContextClientVersion(2)
        glSurfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        glSurfaceView.setRenderer(arManager)
        glSurfaceView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY

        // Forward touch events to ArManager for hit-testing
        @SuppressLint("ClickableViewAccessibility")
        glSurfaceView.setOnTouchListener { _, event ->
            arManager.onTouch(event)
            true
        }
    }

    override fun getView(): View = glSurfaceView

    override fun dispose() {
        arManager.destroy()
        methodChannelHandler.dispose()
        glSurfaceView.onPause()
    }

    /**
     * Called when the activity resumes.
     * Must be forwarded from [MainActivity] or a lifecycle observer.
     */
    fun onResume() {
        glSurfaceView.onResume()
        arManager.resume()
    }

    /**
     * Called when the activity pauses.
     */
    fun onPause() {
        arManager.pause()
        glSurfaceView.onPause()
    }
}
