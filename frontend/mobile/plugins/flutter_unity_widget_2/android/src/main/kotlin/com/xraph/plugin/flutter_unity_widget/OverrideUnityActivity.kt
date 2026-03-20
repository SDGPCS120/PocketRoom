package com.xraph.plugin.flutter_unity_widget

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.util.Log
import android.view.Gravity
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.FrameLayout
import com.unity3d.player.UnityPlayerActivity
import com.unity3d.player.UnityPlayerForActivityOrService
import java.util.Objects

class OverrideUnityActivity : UnityPlayerActivity() {
    private lateinit var mMainActivityClass: Class<*>
    private val mainHandler = Handler(Looper.getMainLooper())
    private var pendingCartPayload: String? = null
    private var cartDispatchAttempts = 0

    private val cartDispatchRunnable = object : Runnable {
        override fun run() {
            val payload = pendingCartPayload
            if (payload.isNullOrBlank()) {
                return
            }

            cartDispatchAttempts += 1
            try {
                UnityPlayerUtils.postMessage("FlutterCartBridge", "ReceiveCartPayload", payload)
                Log.i(LOG_TAG, "Dispatched cart payload to Unity (attempt $cartDispatchAttempts)")
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Failed to dispatch cart payload", e)
            }

            if (cartDispatchAttempts < MAX_CART_DISPATCH_ATTEMPTS) {
                mainHandler.postDelayed(this, CART_DISPATCH_INTERVAL_MS)
            } else {
                pendingCartPayload = null
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        instance = this
        this.window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        addBackButton()
        val intent = intent
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            handleIntent(intent)
        }
    }

    private fun unloadPlayer() {
        mUnityPlayer?.unload()
        showMainActivity()
    }

    private fun quitPlayer() {
        mUnityPlayer?.destroy() // unity 2023+ has no quit
    }

    private fun showMainActivity() {
        val intent = Intent(this, mMainActivityClass)
        intent.putExtra("showMain", true)
        intent.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
        startActivity(intent)
    }

    private fun returnToFlutter() {
        showMainActivity()
        finish()
    }

    private fun addBackButton() {
        val button = Button(this).apply {
            text = "Back"
            textSize = 14f
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#CC111111"))
            setOnClickListener {
                Log.i(LOG_TAG, "Native AR back button tapped")
                returnToFlutter()
            }
        }

        val horizontalPadding = dpToPx(16)
        val verticalPadding = dpToPx(10)
        button.setPadding(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding)

        val params = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            leftMargin = dpToPx(16)
            topMargin = dpToPx(24)
        }

        addContentView(button, params)
    }

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            resources.displayMetrics
        ).toInt()
    }

    override fun onUnityPlayerUnloaded() {
        showMainActivity()
    }

    override fun onLowMemory() {
        super.onLowMemory()
        // copied from Unity 2023 UnityPlayerForActivityOrService onLowMemory()
        mUnityPlayer.onTrimMemory(UnityPlayerForActivityOrService.MemoryUsage.Critical);
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            handleIntent(intent)
        }
        setIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        // Set activity not fullscreen
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            val st = Objects.requireNonNull(intent.extras)?.get("flutterActivity") as Class<*>
            mMainActivityClass = st
            // Set activity not fullscreen
            if (Objects.requireNonNull(intent.extras)?.getBoolean("fullscreen") == true) {
                val fullscreen = intent.extras?.getBoolean("fullscreen")
                if (!fullscreen!!) {
                    this.window.addFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN)
                    this.window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
                } else {
                    this.window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
                }
            }
            // Unloads unity
            if (Objects.requireNonNull(intent.extras)?.containsKey("unload") == true) {
                mUnityPlayer?.unload()
            }

            pendingCartPayload = intent.extras?.getString("cartPayload")
            if (!pendingCartPayload.isNullOrBlank()) {
                scheduleCartPayloadDispatch()
            }
        }
    }

    private fun scheduleCartPayloadDispatch() {
        cartDispatchAttempts = 0
        mainHandler.removeCallbacks(cartDispatchRunnable)
        mainHandler.postDelayed(cartDispatchRunnable, INITIAL_CART_DISPATCH_DELAY_MS)
    }

    override fun onBackPressed() {
        Log.i(LOG_TAG, "onBackPressed called")
        returnToFlutter()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
    }

    override fun onPause() {
        super.onPause()
        this.mUnityPlayer?.pause()
    }

    override fun onResume() {
        super.onResume()
        this.mUnityPlayer?.resume()
    }

    override fun onDestroy() {
        mainHandler.removeCallbacks(cartDispatchRunnable)
        super.onDestroy()
        instance = null
    }

    companion object {
        var instance: OverrideUnityActivity? = null
        internal val LOG_TAG = "OverrideUnityActivity"
        private const val INITIAL_CART_DISPATCH_DELAY_MS = 1500L
        private const val CART_DISPATCH_INTERVAL_MS = 1000L
        private const val MAX_CART_DISPATCH_ATTEMPTS = 6
    }
}
