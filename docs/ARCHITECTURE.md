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

---

## 4. Package & Integration Architecture

The project is structured as a **reusable Flutter Plugin**:

```
cool_ar/ (or ar_engine/)
├── lib/                        <-- Reusable Dart API exported to consumers
│   ├── ar_engine.dart          <-- Public export contract (ARSession, ARView, models)
│   └── src/...
├── android/                    <-- Self-contained native Android library
│   ├── build.gradle.kts        <-- ARCore / Filament dependencies
│   └── src/main/...            <-- ArPlatformView, ArManager, renderers
├── ios/                        <-- Self-contained native iOS library (RealityKit)
└── example/                    <-- Standalone test harness application
    ├── lib/main.dart           <-- Demo screen used for physical device validation
    └── android/                <-- Runner app executing tests without host app
```

### Host E-Commerce App Consumption
The existing e-commerce application adds this engine as a dependency:
```yaml
dependencies:
  ar_engine:
    path: ../cool_ar # or git repo
```
Flutter automatically merges the AndroidManifest permissions (camera, ARCore) and links native platform views without requiring manual copy-pasting of native Kotlin/Gradle files into the e-commerce project.

---

## 5. Multi-User Collaboration Topology

Shared AR sessions require decoupling **spatial coordinate alignment** from **live interaction streaming**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      Tier 1: Spatial Alignment                         │
│                    (Establish Shared Coordinate (0,0,0))               │
│                                                                        │
│   • Primary: Google Cloud Anchors (cross-platform Android + iOS)      │
│   • Offline Fallback: Physical QR Code / Image Marker on room floor    │
│   • Responsibility: Once at session start to align world origins       │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   Tier 2: Real-Time Interaction Sync                   │
│                     (Live 60 FPS Delta Streaming)                      │
│                                                                        │
│   • Transport: Local Wi-Fi (WebSockets / WebRTC) or Cloud (Firebase)   │
│   • Payload: Minimal JSON deltas (move, rotate, scale, place, delete)  │
│   • Note: Cloud Anchors do NOT stream continuous movement deltas       │
└────────────────────────────────────────────────────────────────────────┘
```

