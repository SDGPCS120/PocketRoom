# ADR-002: Tactical Raw ARCore for Phase 1-2, Transitioning to Filament in Phase 3

## Status
Accepted

## Context
For Android AR rendering, modern SceneView (4.x) transitioned to a Jetpack Compose-native architecture (`ARScene {}`), introducing lifecycle friction and unnecessary Compose dependencies when embedded inside Flutter's traditional `PlatformView`.

Conversely, building a full 3D rendering engine (glTF parsing, PBR shaders, IBL, shadow mapping) from scratch with raw OpenGL ES is a multi-year effort that duplicates existing solved technology ("writing a game engine").

## Decision
1. **Phase 1 & 2 (Proof of Concept & Placement):** Use raw ARCore (`com.google.ar:core:1.46.0`) with minimal handwritten OpenGL ES 2.0 (`GLSurfaceView`, `BackgroundRenderer`, `CubeRenderer`). This validates the platform channels and lifecycle with zero external 3D framework bloat.
2. **Phase 3 (GLB Asset Pipeline):** Transition the native rendering layer inside `ArManager` to **Google Filament**. Filament powers Android's system 3D experiences, provides native glTF/GLB loading, PBR materials, IBL, and shadow maps, and renders into standard `SurfaceView` surfaces without requiring Jetpack Compose.

## Consequences
### Positive
- Phase 1 & 2 remained lightweight, dependency-free, and rapid to stabilize.
- Phase 3 avoids writing a custom PBR game engine by delegating to Google's mature mobile renderer.
- The Dart API (`ARSession`, `ARView`) remains 100% unchanged during the renderer swap because rendering specifics are strictly hidden behind `ArManager`.

### Negative / Trade-offs
- The handwritten OpenGL shaders from Phase 1 (`CubeRenderer.kt`, `BackgroundRenderer.kt`) will be retired in Phase 3 when Filament is introduced.
