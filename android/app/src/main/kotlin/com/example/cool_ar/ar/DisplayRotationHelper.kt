package com.example.cool_ar.ar

import android.app.Activity
import android.hardware.display.DisplayManager
import android.view.Display
import android.view.WindowManager
import com.google.ar.core.Session

/**
 * Handles display rotation changes and forwards them to the ARCore session.
 *
 * ARCore needs to know the current display rotation so it can correctly
 * transform camera images and coordinate systems. This helper tracks
 * rotation changes via [DisplayManager.DisplayListener].
 */
class DisplayRotationHelper(private val activity: Activity) : DisplayManager.DisplayListener {

    private var viewportChanged = false
    private var viewportWidth = 0
    private var viewportHeight = 0

    private val display: Display
        get() = activity.getSystemService(WindowManager::class.java).defaultDisplay

    fun onResume() {
        activity.getSystemService(DisplayManager::class.java)
            .registerDisplayListener(this, null)
    }

    fun onPause() {
        activity.getSystemService(DisplayManager::class.java)
            .unregisterDisplayListener(this)
    }

    fun onSurfaceChanged(width: Int, height: Int) {
        viewportWidth = width
        viewportHeight = height
        viewportChanged = true
    }

    /**
     * Updates the session display geometry if the viewport has changed.
     * Must be called once per frame before [Session.update].
     */
    fun updateSessionIfNeeded(session: Session) {
        if (viewportChanged) {
            session.setDisplayGeometry(display.rotation, viewportWidth, viewportHeight)
            viewportChanged = false
        }
    }

    // ─── DisplayManager.DisplayListener ───────────────────────────────────

    override fun onDisplayChanged(displayId: Int) {
        viewportChanged = true
    }

    override fun onDisplayAdded(displayId: Int) {}
    override fun onDisplayRemoved(displayId: Int) {}
}
