# Architectural Constraints & Coding Rules

These rules apply to all AI agents and contributors working in this repository.

## Rule 1: Zero Platform Leaks into Flutter
- Do **NOT** expose ARCore, ARKit, Filament, SceneView, RealityKit, `Anchor`, `HitResult`, or `Plane` to Dart.
- Dart models must remain business-domain only: `FurnitureConfig`, `Transform`, `ARTrackingState`, `AREvent`.

## Rule 2: Single Responsibility Native Subsystems
- Do not add new responsibilities to `ArManager` directly.
- As new capabilities are added (anchors, gestures, assets), extract them into dedicated managers:
  - `AnchorManager`
  - `ObjectRegistry`
  - `GestureManager`
  - `AssetManager`
- `ArPlatformView` owns `ArManager`. `ArManager` must remain non-singleton.

## Rule 3: Native Spatial Authority
- Hit testing must remain 100% native.
- Object IDs must be generated natively (UUID) and communicated to Dart via events.

## Rule 4: Thread Safety across Channels & OpenGL
- All OpenGL and ARCore session calls must happen on the GL Thread.
- All Flutter EventChannel messages must be posted to the Android Main Looper (`ArEventEmitter`).
- MethodChannel calls arrive on Main; any GL operations must be synchronized or posted to the GL surface view.

## Rule 5: Phase Discipline
- Do not implement future phase features prematurely (e.g., do not add GLB loading in Phase 2; do not add collaboration in Phase 3).
- Always consult `docs/ROADMAP.md` and verify against `docs/STATE.md`.

## Rule 6: Multi-Agent Synchronization & Handoff
- Always consult `docs/HANDOFF.md` before proposing or editing files to verify the other developer's active workstream.
- Never edit files currently assigned to the other developer in `docs/HANDOFF.md`.
- Update `docs/HANDOFF.md` and `docs/STATE.md` at the conclusion of every session or feature milestone.
