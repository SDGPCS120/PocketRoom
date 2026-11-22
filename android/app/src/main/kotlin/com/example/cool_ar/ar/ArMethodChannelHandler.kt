package com.example.cool_ar.ar

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Handles Flutter MethodChannel calls and delegates them to [ArManager].
 *
 * Supported methods:
 * - `placeObject` — places a cube at the next tap's hit-test location
 * - `dispose` — cleans up the AR session
 *
 * No `initialize` method — the session starts automatically with the view.
 * No `removeObject` — not needed for Phase 1.
 */
class ArMethodChannelHandler(
    messenger: BinaryMessenger,
    private val arManager: ArManager,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "cool_ar/ar/session")

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "placeObject" -> {
                try {
                    val colorMap = call.argument<Map<String, Double>>("color")
                    val size = call.argument<Double>("size") ?: 0.1

                    val color = if (colorMap != null) {
                        floatArrayOf(
                            colorMap["r"]?.toFloat() ?: 0.3f,
                            colorMap["g"]?.toFloat() ?: 0.7f,
                            colorMap["b"]?.toFloat() ?: 0.3f,
                            colorMap["a"]?.toFloat() ?: 1.0f,
                        )
                    } else {
                        floatArrayOf(0.3f, 0.7f, 0.3f, 1.0f) // default green
                    }

                    arManager.placeObject(color, size.toFloat())
                    result.success(null)
                } catch (e: Exception) {
                    result.error("PLACE_ERROR", e.message, null)
                }
            }

            "dispose" -> {
                arManager.destroy()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }
}
