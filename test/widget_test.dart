import 'dart:ui' show Color;
import 'package:flutter_test/flutter_test.dart';

import 'package:cool_ar/ar/models.dart';

void main() {
  group('Models & Serialization Tests', () {
    test('CubeConfig serialization to map', () {
      const config = CubeConfig(color: Color(0xFF4CAF50), size: 0.1);
      expect(config.size, 0.1);
      expect(config.color, const Color(0xFF4CAF50));

      final map = config.toMap();
      expect(map['size'], 0.1);
      expect(map['color'], isA<Map<String, dynamic>>());
      final colorMap = map['color'] as Map<String, dynamic>;
      expect(colorMap['a'], 1.0);
    });

    test('AREvent trackingStateChanged parsing', () {
      final event = AREvent.fromMap({
        'type': 'trackingStateChanged',
        'data': {'state': 'tracking'},
      });

      expect(event.type, AREventType.trackingStateChanged);
      expect(event.trackingState, ARTrackingState.tracking);
      expect(event.errorMessage, isNull);
    });

    test('AREvent error parsing', () {
      final event = AREvent.fromMap({
        'type': 'error',
        'data': {'message': 'Camera not available'},
      });

      expect(event.type, AREventType.error);
      expect(event.errorMessage, 'Camera not available');
      expect(event.trackingState, isNull);
    });
  });
}
