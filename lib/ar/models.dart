import 'dart:ui' show Color;

/// Configuration for placing a cube in the AR scene.
///
/// Position is determined by the native hit-test at the user's tap location,
/// so Flutter only specifies visual properties.
class CubeConfig {
  /// Color of the cube.
  final Color color;

  /// Size of the cube in meters (uniform scale).
  final double size;

  const CubeConfig({
    this.color = const Color(0xFF4CAF50),
    this.size = 0.1,
  });

  Map<String, dynamic> toMap() => {
        'color': {
          'r': color.r,
          'g': color.g,
          'b': color.b,
          'a': color.a,
        },
        'size': size,
      };
}

/// Types of events the native AR engine can emit.
enum AREventType {
  sessionReady,
  trackingStateChanged,
  error,
}

/// Tracking states reported by ARCore.
enum ARTrackingState {
  tracking,
  paused,
  stopped,
}

/// An event emitted from the native AR session via EventChannel.
class AREvent {
  final AREventType type;
  final Map<String, dynamic> data;

  const AREvent({required this.type, this.data = const {}});

  factory AREvent.fromMap(Map<dynamic, dynamic> map) {
    final typeStr = map['type'] as String;
    final data = Map<String, dynamic>.from(map['data'] as Map? ?? {});

    final type = switch (typeStr) {
      'sessionReady' => AREventType.sessionReady,
      'trackingStateChanged' => AREventType.trackingStateChanged,
      'error' => AREventType.error,
      _ => AREventType.error,
    };

    return AREvent(type: type, data: data);
  }

  /// Convenience getter for tracking state events.
  ARTrackingState? get trackingState {
    if (type != AREventType.trackingStateChanged) return null;
    return switch (data['state']) {
      'tracking' => ARTrackingState.tracking,
      'paused' => ARTrackingState.paused,
      'stopped' => ARTrackingState.stopped,
      _ => null,
    };
  }

  /// Convenience getter for error messages.
  String? get errorMessage =>
      type == AREventType.error ? data['message'] as String? : null;
}
