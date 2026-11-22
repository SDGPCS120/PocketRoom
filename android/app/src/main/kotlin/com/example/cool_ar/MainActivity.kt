package com.example.cool_ar

import com.example.cool_ar.ar.ArEventEmitter
import com.example.cool_ar.ar.ArPlatformViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * MainActivity — registers the AR PlatformView factory and EventChannel.
 *
 * Nothing else goes here. All AR logic lives in the `ar/` package.
 */
class MainActivity : FlutterActivity() {

    private var viewFactory: ArPlatformViewFactory? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // Create shared event emitter (one per engine — the PlatformView
        // instances share it since there's only one EventChannel listener)
        val eventEmitter = ArEventEmitter()
        EventChannel(messenger, "cool_ar/ar/events")
            .setStreamHandler(eventEmitter)

        // Register PlatformView factory
        val factory = ArPlatformViewFactory(this, messenger, eventEmitter)
        viewFactory = factory
        flutterEngine.platformViewsController
            .registry
            .registerViewFactory("cool_ar/ar_view", factory)
    }

    override fun onResume() {
        super.onResume()
        viewFactory?.activeView?.onResume()
    }

    override fun onPause() {
        viewFactory?.activeView?.onPause()
        super.onPause()
    }
}
