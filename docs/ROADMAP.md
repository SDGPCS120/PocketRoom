# AR Furniture Engine — 10-Phase Roadmap

> **Project Goal**  
> Build a lightweight, commercial-grade, cross-platform AR engine that replaces Unity inside a Flutter furniture e-commerce platform.  
> Flutter owns business logic and UI. Native Android (ARCore/Filament) and iOS (ARKit/RealityKit) own spatial computing.

---

## Strategic Principles

1. **Flutter never knows platform internals.** No ARCore, ARKit, SceneView, RealityKit, Anchors, or HitResults exposed to Dart.
2. **Rendering is delegated, not written.** Delegate rendering to Filament (Android) and RealityKit (iOS). We are building an AR engine, not a game engine.
3. **Composition over inheritance.** `FurnitureObject` composed of `Transform`, `Renderable`, `Metadata`, `SelectionState`, `SynchronizationState`.
4. **Single-responsibility subsystems.** No monolithic god objects. Separate managers for Tracking, Gestures, Selection, Assets, Scene, Persistence.
5. **Only ship what we use.** Zero unused bloat (e.g. no unnecessary face/mesh tracking or heavy frameworks).

---

## The 10 Phases

### Phase 0: Architecture Contracts
- **Goal:** Define the public Dart API contracts before implementation.
- **Deliverables:** API surface (`ARSession`, `ARView`, `CubeConfig`/`FurnitureConfig`, events, state models).
- **Status:** Completed.

### Phase 1: Session Foundation
- **Goal:** Prove Flutter communicates cleanly with native ARCore via Platform Channels.
- **Deliverables:**
  - `ARView` (PlatformView hosting native GL surface)
  - `MethodChannel` (`cool_ar/ar/session`) & `EventChannel` (`cool_ar/ar/events`)
  - Camera lifecycle, session resume/pause synchronization
  - Horizontal plane detection
  - Basic camera background feed & prototype cube rendering
- **Status:** Completed & Verified.

### Phase 2: Object Placement (Current Focus)
- **Goal:** Native anchor management and procedural object placement.
- **Deliverables:**
  - Native hit testing on plane polygon
  - Native UUID generation passed up to Flutter (Flutter never generates spatial IDs)
  - One anchor per placed object for independent movement and persistence
  - Placed object registry (`ObjectRegistry`, `AnchorManager`)
  - Remove / clear placed objects via MethodChannel
- **Status:** In Progress.

### Phase 3: GLB Asset Pipeline
- **Goal:** Replace procedural cubes with real 3D furniture models.
- **Architectural Shift:** Replace handwritten OpenGL ES 2.0 renderer with **Google Filament** on Android (and prepare RealityKit for iOS).
- **Deliverables:**
  - Asynchronous `.glb` downloading, decoding, and instancing
  - Multi-tier `AssetRepository` (Memory Cache $\to$ Disk Cache $\to$ Network)
  - Scale normalization (normalizing vendor CAD/3D model scales on load)
  - Bounding box calculation for accurate spatial footprints

### Phase 3.5: Asset Validation Pipeline
- **Goal:** Pre-processing and asset optimization.
- **Deliverables:**
  - Automated asset validator: ensures polycounts, texture sizes, and materials meet mobile budget before ingestion into the e-commerce catalog.

### Phase 4: Interaction System
- **Goal:** Manipulate furniture in AR space.
- **Deliverables:**
  - Touch gestures: 1-finger drag (translation on plane), 2-finger twist (yaw rotation), 2-finger pinch (scale constraints)
  - Centralized `SelectionManager` on the native Scene (selection state belongs to the scene, not Flutter widgets)
  - Visual selection indicators (bounding outline, ground shadow/ring)
  - Delete, duplicate, and transform callbacks to Flutter

### Phase 5: Scene System
- **Goal:** The engine understands an entire room layout.
- **Deliverables:**
  - Scene graph with hierarchical transforms
  - Versioned JSON scene serialization (`version`, `objects`, `metadata`)
  - Immutable snapshot-based Undo/Redo (`HistoryManager`)
  - Scene save, restore, and reset

### Phase 6: E-commerce Integration
- **Goal:** Integrate with the existing Flutter e-commerce app (catalog, cart).
- **Deliverables:**
  - Strict dependency inversion: `Product != FurnitureObject`
  - `FurnitureMapper` and `ProductAdapter` in the application layer
  - App depends on AR engine; AR engine has zero imports from e-commerce app
  - "View Cart in Room" capability: every cart item becomes placeable furniture

### Phase 7: Collaboration (Multiplayer)
- **Goal:** Shared AR sessions between multiple users in the same room.
- **Deliverables:**
  - Server-authoritative state synchronization (avoiding premature CRDT complexity)
  - Real-time delta updates: only send creation, deletion, transform, and selection changes
  - Object ownership management (`ownerId`) for conflict resolution during concurrent manipulation

### Phase 8: Persistence
- **Goal:** Saved rooms persist across days and app restarts.
- **Deliverables:**
  - Unified `PersistenceProvider` interface
  - Android: Google Cloud Anchors / Geospatial
  - iOS: ARWorldMap / RealityKit persistence
  - Decoupling furniture layout metadata from tracking anchor data

### Phase 9: Rendering Quality & Realism
- **Goal:** Photorealistic furniture rendering for purchase confidence.
- **Deliverables:**
  - Real-time contact shadows and plane shadows
  - Depth API / environment occlusion (furniture hidden behind walls and real objects)
  - Image-Based Lighting (IBL) & HDR environment reflection probes
  - Distance-based Level of Detail (LOD)

### Phase 10: Production Engine & Package Extraction
- **Goal:** Extract engine into a standalone, reusable package (`ar_engine`).
- **Deliverables:**
  - Standalone package structure (`packages/ar_engine/`)
  - In-engine performance monitoring (FPS HUD, memory budget, tracking telemetry)
  - Automated unit and integration test suite
  - Developer documentation and example showcase app
