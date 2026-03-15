package com.unity3d.player;

import android.app.Activity;
import android.widget.FrameLayout;

public class UnityPlayerForActivityOrService extends UnityPlayer {
    public enum MemoryUsage {
        Critical
    }

    public UnityPlayerForActivityOrService(
        Activity activity,
        IUnityPlayerLifecycleEvents lifecycleEvents
    ) {
        super(activity);
    }

    public FrameLayout getFrameLayout() {
        return this;
    }

    public void onTrimMemory(MemoryUsage memoryUsage) {}
}
