# Markdown File Guide for Humans (Non-Agent Guide)

> **Welcome!** If you are a human developer, team member, or reviewer opening this repository, this guide explains in plain English what is going on, why there are several `.md` files, and how you and your AI agents use them to build this project without chaos.

---

## 1. Why Are There So Many Markdown Files?

When building software with AI coding agents (like Google Antigravity, Claude Code, or Cursor), the biggest pitfall is **Context Amnesia & Architectural Drift**:
- Each AI chat session starts with zero memory of yesterday's conversations.
- Your colleague's AI agent knows **nothing** about what your AI agent did.
- If decisions are made only inside a temporary chat window, the agents will quickly invent duplicate classes, overwrite each other's work, and break the architecture.

**The solution:** The repository's Markdown (`.md`) files act as the **permanent shared brain** of the project. Both humans and AI agents read and update these files so everyone stays 100% aligned across days, branches, and machines.

---

## 2. Quick Cheat Sheet: The Entire Documentation System

| File | What It Is in Plain English | Who Writes It? | When Should You Read It? |
|---|---|---|---|
| [README.md](README.md) | **The Front Door:** What is this project, why does it exist, and how to run it. | Human / Agent | First time opening the project. |
| [docs/PRD.md](docs/PRD.md) | **Product Requirements:** Target users, business goals, and what features are in/out of scope. | Human / Agent | When you need clarity on *what* we are building and *why*. |
| [docs/ROADMAP.md](docs/ROADMAP.md) | **The 10-Phase Plan:** The exact milestone sequence from Phase 0 to commercial release. | Human / Agent | When planning what to build next. |
| [docs/STATE.md](docs/STATE.md) | **The Live Dashboard:** What works right now, what is broken, and current technical debt. | Agent updates automatically | Before starting any work or after fixing bugs. |
| [docs/HANDOFF.md](docs/HANDOFF.md) | **The Teammate Handoff Log:** Notes between you and your colleague (what was done, what is in-flight). | Both humans & agents | At the start & end of every coding session. |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | **The Technical Blueprint:** Diagrams, threading boundaries, and platform channel specs. | Architect / Agent | When building new features or changing APIs. |
| [docs/TESTING.md](docs/TESTING.md) | **The QA Runbook:** How to run unit tests, mock channels, and test on physical phones. | Both | Before pushing code or signing off a milestone. |
| [docs/TEAMWORK.md](docs/TEAMWORK.md) | **The Collaboration Rules:** How 2+ devs and agents work together without merge conflicts. | Humans | When onboarding teammates. |
| [docs/decisions/](docs/decisions/) | **Architecture Decision Records (ADRs):** Explains *why* we chose Tech A over Tech B. | Both | When someone asks "Why aren't we using Unity/OpenGL/etc.?" |
| [AGENTS.md](AGENTS.md) | **The AI Law Book:** Strict rules the AI must follow on every single turn. | Human rules for AI | Read once to understand the AI's constraints. |
| [.agents/rules/](.agents/rules/) | **Modular AI Rules:** Specific technical guardrails (e.g. zero ARCore types in Dart). | Built for the AI | The AI reads these automatically. |
| [.agents/skills/](.agents/skills/) | **AI Workflows:** Step-by-step procedures for the AI to advance phases safely. | Built for the AI | The AI executes these automatically. |

---

## 3. Deep Dive: What Each File Does

### 📖 High-Level Product Files

#### 1. [README.md](README.md)
- **Purpose:** The standard GitHub landing page.
- **Key Takeaway:** Explains that this project is a **custom, lightweight AR engine** replacing **Unity** in the PocketRoom furniture e-commerce platform. It provides installation steps and verification commands.

#### 2. [docs/PRD.md](docs/PRD.md) (Product Requirements Document)
- **Purpose:** Defines the business case, user personas (Home Shoppers, Couples, Stylists), and non-functional requirements (60 FPS, $\le 12\text{ MB}$ package size, battery efficiency).
- **Key Takeaway:** Outlines what is **out of scope** (no face filters, no game physics). If an AI agent suggests adding a random feature, check the PRD to see if it's actually wanted!

---

### 🗺️ Planning & Memory Files

#### 3. [docs/ROADMAP.md](docs/ROADMAP.md) (Master 10-Phase Roadmap)
- **Purpose:** Breaks down the entire engine build into 10 clean, sequential phases:
  - *Phase 1:* Camera session & plane detection (Done)
  - *Phase 1.5:* Restructure to Flutter Plugin package (Current)
  - *Phase 2:* Object placement & native UUID registry
  - *Phase 3:* 3D GLB model loading via Google Filament
  - *Phase 4:* Touch gestures (drag to move, twist to rotate)
  - *Phase 5:* Full room scene serialization (save/restore room layout)
  - *Phase 6:* E-commerce cart bridge ("View Cart in Room")
  - *Phase 7:* Multiplayer shared AR sessions
  - *Phase 8:* Room persistence across app restarts
  - *Phase 9:* Realistic lighting, shadows & occlusion
  - *Phase 10:* Production release & telemetry
- **Rule:** Never let an AI agent build Phase 4 features while we are still on Phase 2!

#### 4. [docs/STATE.md](docs/STATE.md) (Live Implementation State)
- **Purpose:** The single source of truth for what currently works and what is broken.
- **How to use it:** Whenever a bug is fixed or a capability is built, the agent updates this file. If you come back to the project after a 2-week break, open this file to immediately know where things stand.

#### 5. [docs/HANDOFF.md](docs/HANDOFF.md) (The Teammate Handoff Log)
- **Purpose:** Direct communication bridge between **Developer 1** and **Developer 2**.
- **How to use it:** It has an "Active Workstreams" table. If you are working on the native Android code, put your name next to `android/...`. Your colleague's agent will see that and avoid modifying your files!

---

### 🛠️ Architecture, Testing & Decisions

#### 6. [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) (Technical Design)
- **Purpose:** Details the system topology and invariant rules:
  - Flutter only knows business concepts (`FurnitureConfig`, `Transform`).
  - Native Kotlin owns spatial calculations (`ARCore`, `Filament`).
  - Explains the two-tier multiplayer structure (Cloud Anchors for alignment + WebSockets for live movement).

#### 7. [docs/TESTING.md](docs/TESTING.md) (QA & Testing Runbook)
- **Purpose:** Explains how to test without needing a physical phone for every minor change:
  - Run `flutter test` for instant automated Dart tests.
  - Run `flutter analyze` for static code analysis.
  - Follow the **5-Point Physical Device Runbook** before completing any roadmap milestone.

#### 8. [docs/decisions/](docs/decisions/) (Architecture Decision Records)
- **Purpose:** Short 1-page notes documenting major architectural choices:
  - `ADR-001`: Why we replaced Unity with native platform channels.
  - `ADR-002`: Why we used raw ARCore for Phase 1 and will migrate to Google Filament in Phase 3.
  - `ADR-003`: Why we are structuring the project as a Flutter Plugin package.
  - `ADR-004`: Why multiplayer separates Cloud Anchors from real-time WebSockets.

---

### 🤖 AI Agent Control Files

#### 9. [AGENTS.md](AGENTS.md) & [.agents/rules/](.agents/rules/)
- **Purpose:** These files are **automatically injected into your AI agent's prompt** on every single message in Antigravity.
- **What they enforce:**
  - The AI must read `docs/STATE.md` and `docs/HANDOFF.md` before writing code.
  - The AI must never reformat unrelated code.
  - The AI must never fake that a test or build passed.
  - The AI must never expose raw ARCore/ARKit types into Dart.

---

## 4. Human Best Practices: How to Work Smoothly

1. **When You Start a Session:**
   - You don't need to type a massive prompt. Just tell your agent what you want to work on. The agent will automatically read `AGENTS.md`, `docs/STATE.md`, and `docs/HANDOFF.md`.
2. **Before You Push Code:**
   - Run the 3 verification commands (or tell your agent to run them):
     ```bash
     flutter analyze
     flutter test
     flutter build apk --debug
     ```
3. **If You and Your Teammate are Working at the Same Time:**
   - Check `docs/HANDOFF.md` first.
   - Work on separate branches (e.g. `feat/dev1-anchors` vs `feat/dev2-dart-models`).
   - Slicing by layer (one person on native Android, one person on Flutter/Dart) results in zero merge conflicts!
