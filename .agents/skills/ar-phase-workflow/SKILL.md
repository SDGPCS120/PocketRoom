---
name: ar-phase-workflow
description: >-
  Use this skill when planning, implementing, or completing a phase from docs/ROADMAP.md.
  Ensures architectural compliance, build verification, and state tracking.
---

# AR Phase Development Workflow

Use this workflow whenever advancing the engine to a new phase or adding a major milestone.

## Step 1: Pre-Implementation Verification
1. Read [docs/STATE.md](file:///c:/Users/User/AndroidStudioProjects/cool_ar/docs/STATE.md) to inspect current implementation and open technical debt.
2. Read the target phase specification in [docs/ROADMAP.md](file:///c:/Users/User/AndroidStudioProjects/cool_ar/docs/ROADMAP.md).
3. Validate against the core rules in [.agents/rules/architecture.md](file:///c:/Users/User/AndroidStudioProjects/cool_ar/.agents/rules/architecture.md).
4. Explain architectural decisions before modifying any code.

## Step 2: Implementation Guidelines
- **Dart Layer:** Modify `lib/ar/` only to support the current phase's domain contracts.
- **Native Android Layer:** Place new spatial subsystems under `android/app/src/main/kotlin/com/example/cool_ar/ar/`.
  - Decompose large classes into single-responsibility components (`AnchorManager`, `ObjectRegistry`, etc.).
  - Maintain thread boundaries between Main and GL threads.
- **Do not introduce future phase concepts** (e.g. no networking in Phase 2).

## Step 3: Verification
1. Run `flutter analyze` (must pass with 0 errors and 0 warnings).
2. Run `flutter test` (all automated unit and channel mock tests must pass).
3. Run `flutter build apk --debug` to verify native compilation and dependency packaging.
4. Review changes against the 5 Core Principles in [AGENTS.md](file:///c:/Users/User/AndroidStudioProjects/cool_ar/AGENTS.md).
5. Verify against the Physical Device Runbook in [docs/TESTING.md](file:///c:/Users/User/AndroidStudioProjects/cool_ar/docs/TESTING.md) when testing on hardware.

## Step 4: Documentation Update
1. Update [docs/STATE.md](file:///c:/Users/User/AndroidStudioProjects/cool_ar/docs/STATE.md) with newly completed capabilities and any new technical debt.
2. Summarize what was built and what the next immediate step is.
