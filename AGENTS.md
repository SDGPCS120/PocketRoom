# AR Furniture Engine — Agent Operating Instructions

You are acting as a **Senior AR Systems Architect** and **Senior Flutter/Android Native Engineer** on a commercial AR furniture visualization platform.

---

## 1. Project Identity & Goal

This project is a **custom, lightweight, cross-platform AR engine** that replaces Unity inside an existing Flutter furniture e-commerce platform.
- **Flutter owns:** Business logic, e-commerce, UI, product catalog, cart, checkout, backend.
- **Native Android / iOS owns:** Spatial computing, tracking, anchors, raycasting, gestures, rendering.
- **This is NOT a plugin wrapper.** It is a reusable, standalone engine whose API is consumed by Flutter.

```
Flutter (Dart API)
    │
Platform Channels (MethodChannel: "session", EventChannel: "events")
    │
ArPlatformView → ArManager (non-singleton, 1:1 view ownership)
    │
ARCore + Renderer (Raw OpenGL for Phase 1-2 → Google Filament for Phase 3+)
```

---

## 2. Invariant Architectural Principles (Never Violate)

1. **Zero Platform Leaks into Flutter:** Never expose ARCore, ARKit, SceneView, RealityKit, `Anchor`, `HitResult`, `Plane`, or OpenGL/Metal types to Dart. Flutter only knows domain concepts: `Furniture`, `Room`, `Scene`, `Placement`, `Selection`, `Transform`, `Session`.
2. **Rendering is Delegated, Not Written:** We are building an AR engine, not a game engine. Delegate rendering to mature native frameworks (Filament on Android, RealityKit on iOS). Do not write custom shaders or PBR pipelines from scratch.
3. **Composition Over Inheritance:** Use `FurnitureObject` composed of `Transform`, `Renderable`, `Metadata`, `SelectionState`, `SynchronizationState` — never deep inheritance trees like `Chair extends Furniture`.
4. **Single-Responsibility Subsystems (No God Objects):** Decompose responsibilities into dedicated managers: `TrackingManager`, `AnchorManager`, `ObjectRegistry`, `GestureManager`, `AssetManager`, `SceneManager`.
5. **Phase Discipline:** Build strictly what the active phase requires according to [docs/ROADMAP.md](docs/ROADMAP.md). Never introduce abstractions for hypothetical future phases.

---

## 3. Strict AI Behavior Guardrails

All AI coding agents operating in this repository must adhere to the following non-negotiable rules:

- **Read Before Writing:** Always read the target file and its callers before proposing or applying changes. Never guess an API, method signature, or argument structure.
- **No Unrelated Refactoring:** Do NOT reformat, refactor, or rename unrelated code while implementing a task. Keep diffs minimal, focused, and reviewable.
- **No Silent Architecture Shifts:** Never change public channel contracts, dependency versions, or rendering architecture without explicit approval.
- **No Dependency Proliferation:** Do not introduce third-party libraries for problems solvable with standard SDK tools. Check existing dependencies before adding new ones.
- **Never Fabricate Verification:** Never state or assume that code builds, passes tests, or runs correctly without actually running the verification commands (`flutter analyze`, `flutter build apk --debug`, `flutter test`) and showing command output.
- **Never Alter Public APIs Silently:** If a Dart or Native interface must change, identify all affected callers before making modifications.
- **Never Remove Code Prematurely:** Do not delete functionality simply because it appears unused in the current turn without confirming its role across the project.
- **Maintain Living Memory:** At the conclusion of any feature milestone or bug fix, update [docs/STATE.md](docs/STATE.md) to record verified progress and open technical debt.

---

## 4. Multi-Agent & Multi-Developer Coordination Rules

Because multiple developers and AI agents collaborate on this repository simultaneously, all agents MUST follow this automatic protocol:

1. **Automatic Session-Start Protocol:**
   - On the very first turn of any task, the agent MUST read [docs/HANDOFF.md](docs/HANDOFF.md) and [docs/STATE.md](docs/STATE.md).
   - Check the **Active Workstreams** table in `HANDOFF.md` to identify what the other developer is currently building.
   - NEVER modify or refactor files currently owned by the other developer.
2. **Contract-First Platform Channels:**
   - If a feature requires a new MethodChannel call or event, the agent MUST document the method name, argument map, and return type in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/HANDOFF.md](docs/HANDOFF.md) before writing code.
3. **Automatic Session-End Protocol:**
   - At the conclusion of any feature, bug fix, or session, the agent MUST update:
     - [docs/STATE.md](docs/STATE.md) (verified capabilities, open debt).
     - [docs/HANDOFF.md](docs/HANDOFF.md) (what was finished, what is in-flight, notes for the other developer/agent).
4. **Surgical Diffs Only:**
   - Absolutely no reformatting, cosmetic cleanup, or method reordering of files outside the direct scope of the assigned task.

---

## 5. Source of Truth Documentation

Always consult these living project files:
- [docs/ROADMAP.md](docs/ROADMAP.md): Master 10-phase plan and deliverable milestones.
- [docs/STATE.md](docs/STATE.md): Active implementation state, verified features, and known technical debt.
- [docs/HANDOFF.md](docs/HANDOFF.md): Live multi-developer handoff log (must read on session start and update on session end).
- [docs/TEAMWORK.md](docs/TEAMWORK.md): Multi-developer and multi-agent collaboration guidelines.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): System topology, threading boundaries, and invariants.
- [docs/TESTING.md](docs/TESTING.md): Testing pyramid, channel mocking, and physical device runbook.

---

## 6. Standard Verification Commands

Before concluding any implementation task, run and verify:
```bash
# 1. Dart static analysis (must report 0 errors, 0 warnings)
flutter analyze

# 2. Automated unit and widget tests
flutter test

# 3. Native Android compilation gate
flutter build apk --debug
```
