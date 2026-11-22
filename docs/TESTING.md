# Testing Strategy & Quality Assurance Protocol

> **Core Principle**  
> We cannot bring a physical living room into a continuous integration runner. Therefore, testing in this project is divided into **automated offline verification** (Dart unit tests, platform channel mocks, compilation gates) and **deterministic hardware verification** (ARCore playback, physical device runbook).

---

## 1. The 4-Tier Testing Pyramid

```
                ┌─────────────────────────────────┐
                │     Physical Device Runbook     │  Manual protocol before phase sign-off
                │    (Camera, Plane stability)    │
                ├─────────────────────────────────┤
                │   ARCore Recording & Playback   │  Deterministic sensor replay
                │     (Repeatable AR testing)     │
                ├─────────────────────────────────┤
                │     Native Android Unit Tests   │  Kotlin math, handlers, event emitter
                │      (Robolectric / JUnit)      │
                ├─────────────────────────────────┤
                │    Dart Unit & Widget Tests     │  Models, channel mocks, UI overlays
                │         (flutter test)          │  Runs in milliseconds on CI
                └─────────────────────────────────┘
```

---

## 2. Tier 1: Dart Unit & Channel Mocking

Dart logic must be testable in complete isolation without connecting an Android device or starting an AR session.

### Running Automated Dart Tests
```bash
flutter test
```

### Mocking Platform Channels in Tests
When testing `ARSession` or widgets that communicate with native AR, use `TestDefaultBinaryMessengerBinding` to intercept platform channel calls:

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cool_ar/ar/ar_session.dart';
import 'package:cool_ar/ar/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ARSession.placeObject dispatches correct method call', () async {
    final session = ARSession();
    MethodCall? capturedCall;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('cool_ar/ar/session'),
      (MethodCall call) async {
        capturedCall = call;
        return null;
      },
    );

    await session.placeObject(const CubeConfig(color: Color(0xFF4CAF50), size: 0.1));

    expect(capturedCall, isNotNull);
    expect(capturedCall!.method, 'placeObject');
    expect(capturedCall!.arguments['size'], 0.1);
  });
}
```

---

## 3. Tier 2: Native Android Unit Testing

Native subsystems that do not require an active camera sensor must be tested via JUnit on the JVM:
- **`ArEventEmitter`:** Verify thread dispatching (ensuring events called from background threads post to the Android Main Looper).
- **`ArMethodChannelHandler`:** Verify argument validation and error code propagation.
- **Math & Matrix Utilities:** Model-View-Projection matrix calculations, scale normalization, and bounding box math.

---

## 4. Tier 3: ARCore Recording & Playback

ARCore provides a deterministic testing mechanism through the **Recording and Playback API**:
1. A physical walk-through of a room is recorded once onto an `.mp4` dataset containing synchronized video and 6-DoF IMU data using `session.startRecording()`.
2. In test environments or local development, ARCore is configured via `session.setPlaybackDatasetUri()`.
3. ARCore replays the recorded sensor streams, producing repeatable planes, feature points, and hit-test results at exact frame timestamps. This allows regression testing of spatial calculations without moving a physical device.

---

## 5. Tier 4: Physical Device Verification Runbook

Before closing any phase milestone in [docs/ROADMAP.md](ROADMAP.md), the code must pass this 5-point manual protocol on a physical ARCore-supported device:

| Test Case | Scenario | Expected Outcome |
|---|---|---|
| **1. Cold Boot & Permissions** | Fresh install, launch app. | Prompts camera permission. Status transitions from *"Starting AR session"* $\to$ *"Move device to detect surfaces"* without crashing. |
| **2. Background Cycle** | App in active AR tracking $\to$ press Home $\to$ wait 5 seconds $\to$ resume. | Camera feed resumes instantly. Zero `SessionPausedException`, zero black screen. |
| **3. Tracking Loss & Recovery** | Cover camera lens with hand for 3 seconds, then uncover. | State transitions `TRACKING` $\to$ `PAUSED` $\to$ `TRACKING`. Anchored objects remain in their physical positions upon recovery. |
| **4. Anchor Drift Check** | Place an object on the floor $\to$ walk 3 meters away $\to$ turn 180° $\to$ walk back. | Placed object remains locked to the exact physical spot on the floor. |
| **5. Memory & Performance** | Run active AR session continuously for 5 minutes. | Frame rate remains stable (~60 FPS). No native texture leaks or runaway heap allocation. |

---

## 6. Pre-Commit Verification Gate

Before committing any code or declaring a task complete:
```bash
# Must pass with 0 errors and 0 warnings:
flutter analyze

# Must pass all automated tests:
flutter test

# Must compile the native Android bundle:
flutter build apk --debug
```
