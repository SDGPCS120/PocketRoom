package com.unity3d.player;

import android.content.Context;
import android.widget.FrameLayout;

public class UnityPlayer extends FrameLayout {
    public UnityPlayer(Context context) {
        super(context);
    }

    public static void UnitySendMessage(String gameObject, String methodName, String message) {
        // Stubbed for non-AR builds.
    }

    public void pause() {}

    public void resume() {}

    public void unload() {}

    public void destroy() {}

    public void windowFocusChanged(boolean hasFocus) {}
}
