# ADR-003: Flutter Plugin Architecture with Built-in Example Harness

## Status
Accepted

## Context
The goal is to replace Unity inside an existing Flutter furniture e-commerce platform. Initially, Phase 1 was prototyped as a standard Flutter Application (`cool_ar`) to prove basic platform channel communication.

However, keeping the engine as a standard application means that integrating it into the existing e-commerce app would require manually copying native Kotlin source files, Gradle dependencies, and manifest entries into the host app runner. Deferring package extraction to Phase 10 would create substantial migration friction and risk regressions after multiple native subsystems are built.

## Decision
Restructure the project immediately into a standard **Flutter Plugin** (`lib/`, `android/`, `ios/`, `example/`) prior to Phase 2:
1. The engine code lives in `lib/` and `android/`, packaged as a reusable Flutter plugin.
2. The current demo screen is moved to `example/lib/main.dart` to serve as a standalone sandbox test harness.
3. The existing e-commerce app consumes the engine via a path dependency (`path: ../cool_ar`) or private Git dependency.

## Consequences
### Positive
- Direct drop-in replacement for the existing Unity integration (`Navigator.push(...)` opens `ARView(...)`).
- Zero manual native file copying: Flutter automatically merges manifests, permissions, and gradle configurations into the host e-commerce app.
- Full local development and testing remains completely independent via the `example/` runner.

### Negative / Trade-offs
- Slight one-time restructuring of folders and package references.
