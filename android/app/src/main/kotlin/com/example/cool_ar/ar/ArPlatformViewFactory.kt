package com.example.cool_ar.ar

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Factory that creates [ArPlatformView] instances.
 *
 * Registered in [MainActivity] with the view type "cool_ar/ar_view".
 * The Flutter engine calls [create] when an [AndroidView] with this
 * view type is added to the widget tree.
 */
class ArPlatformViewFactory(
    private val activity: Activity,
    private val messenger: BinaryMessenger,
    private val eventEmitter: ArEventEmitter,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    // Track the active view for lifecycle forwarding
    var activeView: ArPlatformView? = null
        private set

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val view = ArPlatformView(activity, messenger, eventEmitter)
        activeView = view
        // Start the AR session immediately
        view.onResume()
        return view
    }
}
