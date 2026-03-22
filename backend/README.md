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
1. Place your Firebase service-account.json and google-services.json securely at the root of the backend folder.
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
