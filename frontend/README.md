# PocketRoom Frontend

Welcome to the Frontend section of the PocketRoom repository. This directory houses the client-facing applications for the PocketRoom platform.

To ensure maximum reach and an optimal user experience across all devices, the frontend is divided into two distinct projects tailored to their respective platforms.

## Project Structure

```text
frontend/
├── mobile/      # The native mobile application
└── web/         # The web browser application
```

### 1. Web Client (/web)
A responsive web dashboard for browser-based tracking and administration.
- Technology: React 19, TypeScript
- Build Tool: Vite
- Highlights: Fast page transitions, strict TypeScript structures, Playwright E2E tests.

Please read the Web README for full local instructions.

### 2. Mobile Client (/mobile)
The native iOS and Android application optimized for mobile users to search the furniture catalog natively.
- Technology: Flutter, Dart
- Key Integrations: Riverpod (State), PayHere (Payments), Speech-to-Text, Unity Widgets.

Please read the Mobile README for complete setup instructions.

## Connecting to the Backend
Both frontends require the NestJS backend API to be running for core NLP and search functionality. Ensure you start the backend server first before actively testing API integrations in either client. See the Root README for complete system launching instructions.
