package com.example.cool_ar.ar

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Thread-safe wrapper around [EventChannel.EventSink].
 *
 * ARCore callbacks may fire on the GL thread. This class ensures
 * all events are dispatched on the main thread so Flutter can receive them.
 *
 * Event format (Map):
 *   { "type": "sessionReady" | "trackingStateChanged" | "error",
 *     "data": { ... } }
 */
class ArEventEmitter : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun emitSessionReady() {
        emit(mapOf("type" to "sessionReady", "data" to emptyMap<String, Any>()))
    }

    fun emitTrackingStateChanged(state: String) {
        emit(mapOf("type" to "trackingStateChanged", "data" to mapOf("state" to state)))
    }

    fun emitError(message: String) {
        emit(mapOf("type" to "error", "data" to mapOf("message" to message)))
    }

    private fun emit(event: Map<String, Any>) {
        mainHandler.post {
            eventSink?.success(event)
        }
    }
}
