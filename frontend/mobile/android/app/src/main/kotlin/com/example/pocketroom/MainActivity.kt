package com.example.pocketroom

import android.content.Intent
import com.xraph.plugin.flutter_unity_widget.FlutterUnityActivity
import com.xraph.plugin.flutter_unity_widget.OverrideUnityActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterUnityActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.pocketroom/unity_ar",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchNativeAr" -> {
                    val cartPayload = call.argument<String>("cartPayload")
                    val intent = Intent(applicationContext, OverrideUnityActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                        putExtra("fullscreen", true)
                        putExtra("flutterActivity", this@MainActivity.javaClass)
                        if (!cartPayload.isNullOrBlank()) {
                            putExtra("cartPayload", cartPayload)
                        }
                    }
                    startActivityForResult(intent, 1)
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}
