# Product Requirements Document (PRD)

## Project: PocketRoom AR Engine (`cool_ar`)

---

## 1. Executive Summary & Vision

**PocketRoom** is a commercial mobile e-commerce application designed to revolutionize home furniture shopping by allowing users to preview, customize, and arrange furniture in their physical spaces before purchasing.

The **AR Engine** is the core spatial computing layer of PocketRoom. It replaces a legacy, heavyweight Unity integration with a bespoke, native-backed AR engine. The engine provides true-to-scale 3D visualization, interactive furniture arrangement, and multi-user collaborative room staging, while keeping the mobile application lightweight, responsive, and battery-friendly.

---

## 2. Problem Statement & Motivation

### The Challenge with Unity
1. **App Footprint:** Unity added significant binary overhead (dozens of MBs), leading to higher user drop-off during app store download on mobile networks.
2. **Resource Exhaustion:** Unity’s runtime demands heavy GPU/CPU allocation, causing thermal throttling, rapid battery depletion, and stutter when alternating between standard e-commerce screens (cart, catalog) and the 3D view.
3. **Dual-Ecosystem Complexity:** Maintaining two completely separate tech stacks (Flutter Dart + Unity C#) created communication bottlenecks and brittle bridge code.

### The Objective
Build a lightweight, dedicated AR engine directly on top of native OS spatial frameworks (**Google ARCore** on Android, **Apple ARKit/RealityKit** on iOS) that integrates seamlessly into Flutter via Platform Channels, reducing app size, improving cold start times, and maximizing device battery life.

---

## 3. Target Users & User Personas

1. **The Home Furnisher (Primary Shopper):**
   - *Need:* Wants to verify whether a dining table or 3-seater sofa will physically fit in their living room without needing a manual tape measure.
   - *Expectation:* Instant surface detection, true-to-scale dimensional accuracy (1:1), and photorealistic materials/lighting.

2. **The Collaborative Co-Shoppers (Couples / Roommates / Family):**
   - *Need:* Shopping together in the same room from separate phones.
   - *Expectation:* Shared AR session where both users see the same virtual furniture in the exact same physical space in real time.

3. **The Interior Stylist / Power User:**
   - *Need:* Staging an entire room layout with multiple items (sofa, rug, coffee table, floor lamp) and saving the arrangement to review later or order as a bundled room.

---

## 4. Scope & Feature Boundaries

### In Scope
- Real-time camera passthrough and 60 FPS surface detection (horizontal and vertical planes).
- True-to-scale 3D model rendering (.glb/.gltf) with Physically-Based Rendering (PBR) materials, realistic shadows, and ambient lighting estimation.
- Direct-touch gestural manipulation: 1-finger plane translation, 2-finger yaw rotation, 2-finger constrained scaling.
- Cart synchronization: Seamlessly importing e-commerce cart items into the AR staging environment.
- Multi-user local collaboration: Shared coordinate frame alignment via Google Cloud Anchors / visual markers, and real-time state synchronization via WebSockets.
- Scene persistence: Saving, exporting, restoring, and undoing/redoing full room furniture configurations.

### Out of Scope (Explicitly Excluded)
- **Face Tracking / Filters:** Not needed for furniture visualization.
- **Custom Game Engine Features:** No physics simulations (ragdolls, gravity-driven collisions), no custom shader languages, no game AI.
- **Standalone 3D Authoring Tools:** No in-app mesh modeling or CAD authoring (models are provided pre-optimized by vendors/catalog).

---

## 5. Functional Requirements by Milestone

### Phase 1: Platform Channel Bridge (Completed)
- Native `PlatformView` hosting hardware camera feed on Android.
- Two-way communication via `MethodChannel` (commands) and `EventChannel` (state updates).
- Surface detection events and basic spatial coordinate anchoring.

### Phase 2: Procedural Object Registry (In Progress)
- Native hit testing on detected plane polygons.
- Independent native anchor allocation with unique UUIDs.
- Multi-object placement, selection, and deletion.

### Phase 3: GLB Asset Pipeline
- Asynchronous downloading and caching of 3D GLB models (Memory $\to$ Disk $\to$ Network).
- Migration from raw OpenGL ES 2.0 to **Google Filament** (Android) for hardware-accelerated PBR rendering.
- Automatic scale normalization for vendor-supplied 3D assets.

### Phase 4: Interactive Gesture System
- Real-time touch gesture recognition: drag-to-move along plane, twist-to-rotate, pinch-to-scale.
- Centralized selection state on the scene graph with visual bounding/selection rings.

### Phase 5: Room Scene System
- Full room scene graph with hierarchical transforms.
- Versioned JSON scene serialization (`version`, `objects`, `metadata`).
- Immutable snapshot-based Undo/Redo mechanism.

### Phase 6: E-Commerce & Cart Bridge
- Bidirectional integration with Flutter e-commerce:
  - "View in Room" from product details.
  - "View Entire Cart" to stage all selected cart items in space simultaneously.
- Clean architectural decoupling: `Product != FurnitureObject` via application-level mappers.

### Phase 7: Collaborative Multiplayer
- Two-tier architecture:
  - **Tier 1:** Spatial coordinate frame alignment using Google Cloud Anchors / QR markers.
  - **Tier 2:** Real-time delta streaming over local Wi-Fi or WebSockets for live move/rotate/delete synchronization.

### Phase 8: Persistence & Room Staging
- Saving room layouts to device storage or cloud backend.
- Restoring previously staged rooms using persistent cloud anchor resolution.

---

## 6. Non-Functional Requirements (NFRs)

| Category | Requirement | Target Metric |
|---|---|---|
| **Performance** | Frame Rate | Stable 60 FPS on mid-range and flagship devices. |
| **Footprint** | Binary Size Addition | Engine package adds $\le 12\text{ MB}$ to final APK (compared to $\ge 60\text{ MB}$ for Unity). |
| **Startup Time** | AR Session Cold Boot | $\le 1.5\text{ seconds}$ from tap to active camera feed. |
| **Memory** | Heap & GPU RAM | Peak memory usage $\le 200\text{ MB}$ with 5 active 3D models. |
| **Thermal / Battery** | Power Draw | Negligible battery drain during standard 5-minute staging sessions; zero runaway CPU spikes. |
| **Compatibility** | Android Min SDK | Android API 24+ (Android 7.0 Nougat) with ARCore support. |
| **Architectural Purity** | Platform Boundary | Zero ARCore/ARKit/Filament imports or leaked types in the Dart layer. |

---

## 7. Success Criteria & Metrics

1. **User Retention & App Size:** Measurable reduction in app uninstalls attributable to lightweight binary size.
2. **Purchase Conversion:** Increased add-to-cart rate from users who preview furniture items in AR before purchasing.
3. **Return Rate Reduction:** Lower return rates on high-ticket furniture items due to accurate 1:1 scale visualization.
4. **Zero-Crash Lifecycle:** Flawless app backgrounding and foregrounding with zero unhandled native ARCore exceptions.
