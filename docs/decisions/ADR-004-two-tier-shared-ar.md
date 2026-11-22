# ADR-004: Two-Tier Architecture for Shared Multi-User AR

## Status
Accepted

## Context
A key product feature is collaborative multi-user AR sessions: two or more users in the same physical room seeing and manipulating the same furniture items in real time.

A common pitfall is expecting spatial anchor services (like Google Cloud Anchors) to handle real-time multiplayer message passing (e.g. streaming 60 FPS drag-to-move coordinates). Cloud Anchors are static and expensive to resolve; they are designed solely to locate a static feature point in 3D space, not to act as a real-time messaging bus.

## Decision
Adopt a strict **two-tier architecture** for shared AR sessions:

1. **Tier 1 — Spatial Origin Alignment (Cloud Anchors / Physical Markers):**
   - Executed once when a participant joins the session.
   - Host device creates an anchor (via ARCore Cloud Anchors or a physical floor marker/QR code).
   - Peer devices resolve the anchor to align their camera coordinate spaces to the exact same $(0,0,0)$ origin.
   - Supported across platforms (ARCore Cloud Anchor SDK is available for both Android and iOS).

2. **Tier 2 — Real-Time State Synchronization (Network Transport):**
   - Independent of the AR tracking framework.
   - Low-latency data channel (Local Wi-Fi WebSockets/UDP, or Cloud WebSockets/Firebase/Supabase).
   - Only streams lightweight JSON delta messages: `{ action: "transform", objectId: "...", x, y, z, yaw, scale }`.
   - Employs object ownership tokens (`ownerId`) to handle concurrent manipulation conflicts.

## Consequences
### Positive
- High-performance, 60 FPS responsive multi-user manipulation.
- Network transport is decoupled from spatial computing; works over local offline Wi-Fi without requiring cloud bandwidth for every touch gesture.
- Clean separation of concerns in the engine codebase (`AnchorManager` handles spatial alignment; `SyncManager` handles delta transport).

### Negative / Trade-offs
- Requires implementing a lightweight network synchronization adapter in Phase 7.
