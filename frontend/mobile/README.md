# PocketRoom Mobile App

The primary native iOS and Android companion app for PocketRoom, bringing smart furniture shopping to the mobile medium.

## Features
- Audio Queries: Implementation with Speech-to-Text for seamless conversational searching on mobile.
- Native Payments: Secure mobile checkout pipelines using PayHere integration.
- 3D Previews: Integrates Flutter Unity Widget to render 3D views of the furniture on supported devices.
- Robust State Tracking: Efficient interface refreshes backed by Riverpod state management.
- Live Database: Pulls active data directly from Firebase Cloud Firestore natively.

## Tech Stack
- Framework: Flutter
- State Management: flutter_riverpod
- Core Services: Firebase Auth, Cloud Firestore, Google Sign-In
- Mobile APIs: Speech-to-Text, PayHere SDK, Permissions Handler, url_launcher
- Extensible UI: GetWidget, Google Fonts, SVG rendering

## Project Structure

```text
mobile/
├── android/            # Native Android codebase
├── ios/                # Native iOS codebase
├── lib/                # Main application logic (Dart components)
├── plugins/            # Wrapped plugins including Unity widget configuration
├── assets/             # Bundled static assets like localized images and banners
├── test/               # Flutter Widget and Unit tests
└── pubspec.yaml        # Configuration definitions for dependencies
```

## Setup Instructions

### Prerequisites
You must have the Flutter SDK natively installed on your operating system along with an initialized IDE (Android Studio or Xcode). Do not forget to link your native applications securely with Firebase by including the provided google-services.json and GoogleService-Info.plist in the native folders.

### Installation
Navigate to this directory and fetch dependencies.
```bash
flutter pub get
```

### Operation
Run the application natively or against a simulator.
```bash
flutter run
```

### Production Build
Generate your release targets.
```bash
# Android APK
flutter build apk --release

# iOS Bundle
flutter build ios --release
```

## Assets Configuration
Contains strict definitions for native splash behaviors, high-resolution launcher icons configured via flutter_launcher_icons, alongside standard imagery assets like get_started_hero.png.
