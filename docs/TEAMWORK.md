# Multi-Developer & Multi-Agent Collaboration Guide

> **Goal:** Enable two or more engineers using AI coding agents (Antigravity, Claude Code, Cursor, Codex) to work on the AR Engine simultaneously without clashing, overwriting code, or accumulating architectural drift.

---

## The Danger of Multi-Agent Development

When working solo, an AI agent relies heavily on the local conversation window. But when **two developers** use agents on different machines:
- **Developer B's agent knows NOTHING about Developer A's chat history.**
- If Developer A makes architectural decisions in chat without committing them to docs, Developer B's agent will make conflicting assumptions.
- Agents love making broad cosmetic refactorings (reformatting, reordering imports). If both agents touch the same file, Git merges become a nightmare.

To prevent this, follow these 5 core team practices:

---

## 1. The 5 Golden Rules of Team Agent Collaboration

### Rule 1: The Repository is the Brain, Not the Chat Window
- **Every design decision, channel change, or bug fix must live in Git** (`docs/STATE.md`, `docs/HANDOFF.md`, or ADRs), not just in your local chat transcript.
- At the start of every turn, tell your agent:  
  `"Read AGENTS.md, docs/STATE.md, and docs/HANDOFF.md before writing code."`
- At the end of every turn, have your agent update `docs/HANDOFF.md`.

### Rule 2: Strict Subsystem / File Ownership (Divide by Boundary)
Never let two agents modify the same file at the same time. Divide work across clear boundaries:

| Model | Dev 1 Focus | Dev 2 Focus | Why It Works |
|---|---|---|---|
| **Layer Slicing (Recommended)** | **Native Android / ARCore** (`android/app/.../ar/`) | **Dart UI / State / Mocks** (`lib/ar/`, `test/`) | Zero merge conflicts; clean channel boundary between them. |
| **Feature Slicing** | **Object Placement / Anchors** (`feature/anchors`) | **Gesture Detection** (`feature/gestures`) | Agents work on separate branch worktrees and separate classes. |

### Rule 3: Contract-First Channel Updates
If a feature requires a new MethodChannel call or event:
1. First, define the method name, argument map, and return type in [docs/ARCHITECTURE.md](ARCHITECTURE.md) or [docs/HANDOFF.md](HANDOFF.md).
2. Commit that contract.
3. Both developers' agents now code against the **exact same contract** without guessing.

### Rule 4: Ban Unrelated Refactoring
This rule is strictly enforced in [AGENTS.md](../AGENTS.md):
- An agent must **never** reformat, rename, or reorganize code outside the immediate scope of its task.
- Diffs must remain surgical and reviewable.

### Rule 5: Run the 3-Point Verification Gate Before Every Push
Neither developer may push code to GitHub that breaks the build or tests:
```bash
flutter analyze           # Must report 0 errors, 0 warnings
flutter test              # All unit & channel tests must pass
flutter build apk --debug # Native Android compilation must succeed
```

---

## 2. The Standard Onboarding Prompt for Dev 2's Agent

When your colleague starts a new AI agent session, they should paste this exact bootstrap prompt:

```text
You are acting as a Senior AR Systems Architect and Flutter/Android Native Engineer working on the PocketRoom AR Engine.

BEFORE making any suggestions or writing any code:
1. Read AGENTS.md at the repository root.
2. Read docs/STATE.md to understand active progress and technical debt.
3. Read docs/HANDOFF.md to see what the other developer recently finished and what is in-flight.
4. Read docs/ROADMAP.md for phase boundaries.

Adhere strictly to the 5 Core Principles and AI Guardrails in AGENTS.md:
- Zero ARCore/ARKit types in Dart.
- No unrelated refactoring.
- Never state code works without running verification commands.
- Update docs/HANDOFF.md at the end of the session.
```

---

## 3. Recommended Git Workflow for the Team

```
               origin/ar-engine (Protected Integration Branch)
                      ▲                       ▲
                      │ PR (Verified)         │ PR (Verified)
                      │                       │
           feat/dev1-anchors            feat/dev2-dart-models
             (Developer 1)                (Developer 2)
```

1. **Create Feature Branch:** Always branch off `origin/ar-engine` (e.g. `git checkout -b feat/dev2-gesture-events`).
2. **Commit Often:** Make small, logical commits with conventional commit prefixes (`feat:`, `fix:`, `docs:`, `test:`).
3. **Rebase Before PR:** Run `git fetch origin && git rebase origin/ar-engine` to pull in teammate changes smoothly.
4. **Never Force-Push to Shared Branches:** Preserve linear, reviewable history.
