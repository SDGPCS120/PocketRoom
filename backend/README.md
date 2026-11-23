# PocketRoom Backend

This is the backend server for PocketRoom, built using the progressive Node.js framework, NestJS. It provides an intelligent furniture search API utilizing Natural Language Processing (NLP) along with essential e-commerce endpoints.

## Features
- AI Search Engine: Smart query parsing and entity extraction for product types, colors, and materials.
- Color Similarity Matching: Finds products in similar shade families.
- ML-Based Relevance: Scores products based on multiple semantic signals.
- Modular Architecture: Heavily decoupled feature sets including Authentication using Firebase Admin.
- Automated API Documentation: Integrated Swagger UI for real-time endpoint exploration.

## Tech Stack
- Framework: NestJS v11 (TypeScript)
- Authentication: Firebase Admin
- NLP Processing: natural package
- Task Queueing: BullMQ
- Documentation: Swagger UI Express
- Validation: Class-validator and Class-transformer

## Project Structure

```text
backend/
├── data/
│   └── products.json          # Formatted product data catalogs
├── src/
│   ├── config/                # Environment configurations
│   ├── features/              # Modular backend services
│   │   ├── search/            # AI Search features and controllers
│   │   └── main.ts            # Entrypoint
│   └── ...
├── test/                      # E2E test suites
├── dockerfile                 # Containerization instructions
└── package.json               # Scripts and dependencies
```

## Setup Instructions

### Environment Setup
1. Configure Firebase Admin with Application Default Credentials. On Cloud Run, use the service's attached identity. For local development, use local ADC or set `GOOGLE_APPLICATION_CREDENTIALS` to a credential file outside the repository. The server also accepts an external path via `FIREBASE_SERVICE_ACCOUNT_PATH`.
2. Initialize environment variables via a .env file as outlined in .env.example.

### Installation and Running
1. Install Dependencies

```bash
npm install
```

2. Run the Development Server

```bash
# standard development
npm run start

# watch mode (recommended)
npm run start:dev
```

3. Production Build

```bash
npm run build
npm run start:prod
```

## API Overview
Once the server is running on the default local port, explore the complete live documentation via Swagger UI. Common domains include `/search`, `/products`, `/orders`, and `/users`.

## Sandbox checkout and administration

Use a sandbox Firebase project for checkout. Set `PAYHERE_MODE=sandbox`, the
sandbox merchant ID, a fresh merchant secret, and the public HTTPS backend origin
using the deployment's secret configuration. Register that origin with PayHere.
PayHere must be able to reach `POST /payments/notify`. Configure no production
keys for this flow. [PayHere Checkout API](https://support.payhere.lk/api-%26-mobile-sdk/checkout-api)

Only Firebase accounts with the server-issued boolean custom claim `admin` have
administrator access. Assign the claim to confirmed administrators via the
Firebase Admin SDK, preserving their other custom claims, and have them refresh
their ID tokens. Firestore profile roles do not grant administrator access.

New orders use catalog prices and own one fulfillment per store. Existing
orders remain visible to their customers and administrators. Review their store
assignments and payment evidence before creating seller fulfillments or taking
action based on an old payment status.
