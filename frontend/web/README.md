# PocketRoom Web Client

The web-based frontend application for the PocketRoom platform, providing seamless e-commerce interactions natively in the browser.

## Features
- Client-Side Routing: Fast routing powered by React Router DOM.
- Instant Server Starts: Sub-second hot module replacement powered by Vite.
- Secure Auth Flow: Integrated deeply with Firebase packages for secure interactions.
- End-to-End Testing: Integrated Playwright environment for robust testing.

## Tech Stack
- Framework: React v19
- Language: TypeScript
- Bundler: Vite
- Networking: Axios
- Authentication: Firebase

## Project Structure

```text
web/
├── src/                   # React source code and views
├── public/                # Static assets
├── eslint.config.js       # Linting rules
├── tsconfig.json          # TypeScript configurations
└── vite.config.ts         # Vite builder setups
```

## Setup Instructions

### Prerequisites
Node.js must be installed. Make sure the NestJS backend is actively running, as this application fetches catalogs from those endpoints.

### Installation
Navigate to this directory.
```bash
npm install
```

### Running the App
Run the local Vite development server.
```bash
npm run dev
```

### Production Build
Create an optimized production bundle.
```bash
npm run build
```
Preview the resultant bundle.
```bash
npm run preview
```

## Screens Overview
Typical implementation includes general storefront navigation, faceted searches communicating with the AI backend service, product detail screens, and a user authentication flow linking Firebase with your shopping cart.
