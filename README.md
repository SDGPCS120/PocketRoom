# PocketRoom AR Engine (`cool_ar`)

> A lightweight, commercial-grade, cross-platform Augmented Reality (AR) engine built for the **PocketRoom** furniture e-commerce platform — replacing Unity with native spatial computing via Flutter Platform Channels.

---

## 1. Project Overview & Mission

**PocketRoom** is a full-featured furniture e-commerce application (product catalog, search, shopping cart, checkout, backend). Previously, 3D and AR furniture visualization was delegated to an embedded **Unity** runtime. 

While Unity worked, it introduced severe costs for a mobile e-commerce platform:
- **Application Bloat:** Added dozens of megabytes to the APK/IPA binary size.
- **Runtime Overhead:** High memory usage, CPU heat, slow cold start times, and heavy battery consumption during browsing.
- **Developer Friction:** Required maintaining two separate project environments (Unity + Flutter) and specialized game engine tooling.

### The Solution
This project is a **custom, lightweight, standalone AR engine** written directly against native spatial computing frameworks (**ARCore** on Android, **ARKit/RealityKit** on iOS) and exposed to Flutter via clean, decoupled Platform Channels.

Flutter acts purely as the business and presentation layer. Native code handles spatial tracking, raycasting, anchors, gestures, and rendering.

```
┌────────────────────────────────────────────────────────┐
│                   Flutter E-Commerce                   │
│          (Products, Cart, Checkout, UI Overlays)       │
└───────────────────────────┬────────────────────────────┘
                            │ Domain Calls (placeObject, transform)
                            ▼
┌────────────────────────────────────────────────────────┐
│                   AR Engine API (Dart)                 │
│                 ARView & ARSession Controller          │
└───────────────────────────┬────────────────────────────┘
                            │ Platform Channels
                            ▼
┌────────────────────────────────────────────────────────┐
│              Native Spatial Engine (Kotlin/Swift)      │
│  ├── Tracking & Anchors (ARCore / ARKit)               │
│  ├── Spatial Hit-Testing & Raycasting                  │
│  └── High-Performance Renderer (Filament / RealityKit) │
└────────────────────────────────────────────────────────┘
```

---

## 2. Key Capabilities & User Experience

- **True-to-Scale Visualization:** Real-world dimensional accuracy (1:1 scale) so customers know exactly whether a sofa, table, or bed fits their room.
- **Instant Camera Passthrough & Plane Detection:** Detects horizontal and vertical surfaces (floors, walls, tables) in real time at 60 FPS.
- **Spatial Object Placement:** Objects are anchored to real-world physical coordinates and remain locked in place as the user moves around the room.
- **Interactive Manipulation (Phases 3–4):** Intuitive touch gestures to slide objects across floor planes (1-finger drag), yaw rotation (2-finger twist), and height/elevation adjustment.
- **Multiplayer Shared Sessions (Phase 7):** Two or more users in the same room can collaborate in real time (one user moves a chair, the other sees it move instantly on their screen) using **Google Cloud Anchors** for coordinate alignment and local Wi-Fi / WebSockets for live state synchronization.
- **Cart-to-Room Integration (Phase 6):** Every item in the customer's e-commerce cart is automatically available as placeable 3D furniture inside the AR space.

---

## 3. Invariant Architectural Principles

1. **Zero Platform Leaks into Flutter:** Never expose ARCore, ARKit, Filament, SceneView, RealityKit, `Anchor`, `HitResult`, or OpenGL types to Dart. Flutter only knows domain concepts: `Furniture`, `Room`, `Scene`, `Placement`, `Selection`, `Transform`, `Session`.
2. **Rendering is Delegated, Not Written:** We build an AR engine, not a game engine. We delegate 3D rendering to mature native frameworks (**Google Filament** on Android, **Apple RealityKit** on iOS).
3. **Composition Over Inheritance:** Modular components (`Transform`, `Renderable`, `Metadata`, `SelectionState`, `SynchronizationState`) over rigid class hierarchies.
4. **Single-Responsibility Subsystems:** Dedicated managers for tracking, anchors, gestures, assets, and scenes. No monolithic "god objects".
5. **Two-Tier Collaboration:** Decouple spatial coordinate alignment (Cloud Anchors / QR codes) from live interaction streaming (WebSockets / WebRTC delta updates).

---

## 4. Documentation Index

The repository maintains an up-to-date, living documentation system:

| Document | Purpose |
|---|---|
| [MD_FILE_GUIDE_FOR_HUMANS.md](MD_FILE_GUIDE_FOR_HUMANS.md) | **Guide for Humans:** Plain-English explanation of all documentation files and how teammates & AI agents collaborate. |
| [docs/PRD.md](docs/PRD.md) | **Product Requirements Document:** Target audience, business goals, user journeys, functional & non-functional requirements. |
| [docs/ROADMAP.md](docs/ROADMAP.md) | **10-Phase Roadmap:** Master milestone sequence from initial session foundation to commercial release. |
| [docs/STATE.md](docs/STATE.md) | **Current Implementation State:** Verified features, active technical debt, and immediate next tasks. |
| [docs/HANDOFF.md](docs/HANDOFF.md) | **Teammate Handoff Log:** Live log of active workstreams and in-flight tasks between collaborators. |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | **System Architecture:** Detailed topology diagrams, threading boundaries, and invariant rules. |
| [docs/TESTING.md](docs/TESTING.md) | **Testing & QA Runbook:** The 4-tier testing pyramid, channel mocking guide, and physical device runbook. |
| [docs/TEAMWORK.md](docs/TEAMWORK.md) | **Teamwork Guide:** Multi-developer and multi-agent collaboration practices. |
| [docs/decisions/](docs/decisions/) | **Architecture Decision Records (ADRs):** Recorded justifications for major architectural forks. |
| [AGENTS.md](AGENTS.md) | **AI Operating Instructions:** Strict operational guardrails for AI coding assistants working in this repository. |

---

## 5. Current Implementation Status

- **Active Milestone:** Completed Phase 1 (Session Foundation) $\to$ Entering Phase 2 (Object Placement & Registry).
- **Verified Capabilities:**
  - Full-screen hardware camera feed via OES texture.
  - Horizontal plane detection.
  - Safe lifecycle management (handling backgrounding/foregrounding without `SessionPausedException`).
  - Procedural cube placement on tap with coordinate anchoring.
  - 100% passing static analysis (`flutter analyze`) and automated unit tests (`flutter test`).

---

## 6. Getting Started & Running the Project

### Prerequisites
- Flutter SDK (3.24+ recommended)
- Android Studio / VS Code
- Physical Android device with **Google Play Services for AR (ARCore)** installed (AR features cannot be tested on standard headless emulators).
- Android SDK Min API: **24** (Android 7.0+)

### Running on a Connected Physical Device
```bash
# 1. Check connected ARCore device
flutter devices

# 2. Run the application
flutter run
```

### Pre-Commit Verification Gate
Before pushing changes or opening a pull request, run the 3-point verification gate:
```bash
# Static analysis (must report 0 errors, 0 warnings)
flutter analyze

# Automated unit & model serialization tests
flutter test

# Native Android compilation check
flutter build apk --debug
```
