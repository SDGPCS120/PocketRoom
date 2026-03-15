package com.unity3d.player;

public interface IUnityPlayerLifecycleEvents {
    default void onUnityPlayerUnloaded() {}

    default void onUnityPlayerQuitted() {}
}
