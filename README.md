# PocketRoom

An intelligent e-commerce platform for furniture featuring an AI-powered search engine. This project combines a high-performance Flutter mobile application, a React-based web interface, and a robust NestJS backend.

## Features
- AI-Powered Search: Natural language processing for understanding user queries like "pink chair under 50000".
- Cross-Platform Clients: Native mobile application for Android and iOS devices, and a fast, responsive web dashboard.
- Unified Backend Architecture: Centralized API managing products, orders, auth, and complex NLP capabilities.
- Semantic Relevance: Matches colors to families and filters out non-matching products natively.

## Tech Stack
- Backend: NestJS, Firebase Admin, Natural (NLP), Swagger UI, BullMQ
- Frontend (Web): React, Vite, TypeScript
- Frontend (Mobile): Flutter, Firebase Core, Riverpod
- Database: Firebase / Firestore

## Project Structure

```text
PocketRoom/
├── backend/          # NestJS RESTful API server
└── frontend/
    ├── mobile/       # Flutter mobile application
    └── web/          # React web application
```

## Setup Instructions
To run the entire stack locally, follow these modular instructions.

### 1. Backend Server Setup
Navigate into the backend directory, provide the necessary service account files for Firebase, and start the development server.
```bash
cd backend
npm install
npm run start:dev
```

### 2. Web Client Setup
In a new terminal, navigate to the web frontend directory. Ensure your backend is running.
```bash
cd frontend/web
npm install
npm run dev
```

### 3. Mobile App Setup
In another terminal, ensure you have a running emulator or a connected physical device.
```bash
cd frontend/mobile
flutter pub get
flutter run
```

## Contribution Guidelines
1. Fork the repository and create your feature branch (e.g., git checkout -b feature/new-search-filter).
2. Follow existing code style patterns within the specific module you are editing.
3. Commit logically and clearly.
4. Push to the branch and open a Pull Request.

## License
This project does not currently have a specified license. All rights reserved.
