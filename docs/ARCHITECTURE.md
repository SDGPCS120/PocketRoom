# System Architecture & Technical Specifications

## 1. High-Level Topology

```
┌────────────────────────────────────────────────────────┐
│                      Flutter UI                        │
│          (ARDemoScreen, Furniture Catalog, Cart)       │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                   AR Engine (Dart)                     │
│               ARView (StatefulWidget)                  │
│                      ARSession                         │
└───────────────┬────────────────────────┬───────────────┘
                │                        │
   MethodChannel("session")     EventChannel("events")
                │                        │
                ▼                        ▼
┌────────────────────────────────────────────────────────┐
│              Native Bridge (Kotlin/Android)            │
│                 ArPlatformViewFactory                  │
│                    ArPlatformView                      │
│                ArMethodChannelHandler                  │
│                    ArEventEmitter                      │
└───────────────────────────┬────────────────────────────┘
                            │ owns (1:1 per view)
                            ▼
┌────────────────────────────────────────────────────────┐
│                    ArManager                           │
│  ├── Tracking & Session (ARCore Session)               │
│  ├── Spatial Anchors & Hit Testing                     │
│  └── Rendering Pipeline (GLSurfaceView / Filament)     │
└────────────────────────────────────────────────────────┘
```

---

## 2. Ownership & Invariants

1. **Non-Singleton `ArManager`:**
   - Every `ArPlatformView` creates and owns its own `ArManager`.
   - Never use global singletons for AR state to ensure clean view lifecycle, testing isolation, and zero memory leaks upon widget unmounting.
2. **Platform Abstraction Boundary:**
   - Flutter code must **never** import or mention ARCore, ARKit, Filament, RealityKit, Anchors, or HitResults.
   - Flutter only communicates in domain primitives: `CubeConfig`, `FurnitureConfig`, `Transform`, `ARTrackingState`.
3. **Native Spatial Authority:**
   - Touch coordinates and screen taps are converted into spatial anchors entirely in native code.
   - Spatial IDs (UUIDs) are generated natively and reported to Dart. Dart is a consumer and command dispatcher, not the spatial coordinator.
4. **Thread Safety & Lifecycle:**
   - ARCore session updates and OpenGL rendering execute on Android's `GLThread`.
   - Method channel commands arrive on the Android UI/Main thread.
   - Event channel emissions are always dispatched on the Main thread via `ArEventEmitter` (`Handler(Looper.getMainLooper())`).
   - Session lifecycle (`resume()` / `pause()`) is guarded by thread-safe flags (`sessionResumed`) to prevent race conditions during cold start.

---

## 3. Technology Stack Decisions

| Subsystem | Android Choice | iOS Choice (Future) | Justification |
|---|---|---|---|
| **Tracking Engine** | ARCore (`com.google.ar:core:1.46.0`) | ARKit | Native OS spatial computing engine; lowest latency and zero overhead. |
| **Renderer (Phase 1-2)** | OpenGL ES 2.0 (`GLSurfaceView`) | RealityKit / Metal | Minimal dependencies for initial platform channel bridge verification. |
| **Renderer (Phase 3+)** | Google Filament | Apple RealityKit | High-performance mobile PBR, GLB model loading, shadows, and environment lighting without writing a custom game engine. |
| **Bridge Mechanism** | Flutter PlatformView (`AndroidView`) | `UiKitView` | Native hardware rendering surface required for camera passthrough and 3D overlay. |
| **Messaging** | `MethodChannel` & `EventChannel` | Same | Idiomatic, robust, decoupled boundary between Dart and platform runtimes. |
