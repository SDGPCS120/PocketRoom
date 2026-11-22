# ADR-001: Custom Platform Channels Over Unity and Generic Plugins

## Status
Accepted

## Context
The e-commerce furniture platform previously used Unity embedded inside Flutter to display and manipulate 3D furniture. While functional, Unity introduced significant overhead:
- Massive binary size (APK/IPA bloat).
- High runtime memory, battery drain, and thermal throttling on mobile devices.
- Cumbersome multi-engine development workflow (Flutter + Unity + Android Studio + Xcode).
- Generic open-source Flutter AR plugins (e.g. `ar_flutter_plugin`) are unmaintained, lag behind modern OS versions, or enforce rigid assumptions about scene structure.

## Decision
Build a custom, lightweight, cross-platform AR engine directly communicating with native spatial computing frameworks via Flutter Platform Channels (`MethodChannel` and `EventChannel`) and `PlatformView` (`AndroidView` on Android, `UiKitView` on iOS).

## Consequences
### Positive
- Minimal binary overhead: no game engine footprint.
- Fast cold starts and direct hardware acceleration.
- Complete control over the spatial computing and lifecycle pipeline.
- Clean separation: Flutter owns e-commerce business logic; native owns spatial tracking and rendering.

### Negative / Trade-offs
- Requires native Android (Kotlin) and iOS (Swift) engineering effort rather than relying on out-of-the-box cross-platform game engines.
