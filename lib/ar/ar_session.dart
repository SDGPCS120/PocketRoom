import 'dart:async';

import 'package:flutter/services.dart';

import 'models.dart';

/// Communicates with the native AR engine via Platform Channels.
///
/// This class is platform-agnostic — it talks through channel names only.
/// The native side (Android/iOS) implements the actual AR logic.
///
/// There is no `initialize()` method. The AR session starts automatically
/// when the native [ARView] is created. Session readiness is communicated
/// back via the [events] stream as an [AREventType.sessionReady] event.
class ARSession {
  static const _methodChannel = MethodChannel('cool_ar/ar/session');
  static const _eventChannel = EventChannel('cool_ar/ar/events');

  StreamSubscription<dynamic>? _eventSubscription;
  final _eventController = StreamController<AREvent>.broadcast();

  bool _isListening = false;

  /// Stream of events from the native AR engine.
  ///
  /// Events include:
  /// - [AREventType.sessionReady] — AR session is initialized
  /// - [AREventType.trackingStateChanged] — tracking / paused / stopped
  /// - [AREventType.error] — error with message
  Stream<AREvent> get events => _eventController.stream;

  /// Start listening to the native EventChannel.
  ///
  /// Called automatically by [ARView] when the native view is created.
  /// Safe to call multiple times — only subscribes once.
  void startListening() {
    if (_isListening) return;
    _isListening = true;

    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          _eventController.add(AREvent.fromMap(event));
        }
      },
      onError: (dynamic error) {
        _eventController.add(AREvent(
          type: AREventType.error,
          data: {'message': error.toString()},
        ));
      },
    );
  }

  /// Place a colored cube at the user's last tap location.
  ///
  /// The native side performs a hit-test against detected planes
  /// and places the cube at the intersection point.
  Future<void> placeObject(CubeConfig config) async {
    await _methodChannel.invokeMethod('placeObject', config.toMap());
  }

  /// Clean up resources.
  ///
  /// Called automatically by [ARView] when the widget is disposed.
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    _isListening = false;
    await _eventController.close();
    await _methodChannel.invokeMethod('dispose');
  }
}
