package com.unity3d.player;

import android.app.Activity;
import android.os.Bundle;

public class UnityPlayerActivity extends Activity {
    protected UnityPlayerForActivityOrService mUnityPlayer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (mUnityPlayer == null) {
            mUnityPlayer = new UnityPlayerForActivityOrService(this, null);
        }
    }

    public void onUnityPlayerUnloaded() {}

    public void onUnityPlayerQuitted() {}
}
