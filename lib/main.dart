import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ar/ar_session.dart';
import 'ar/ar_view.dart';
import 'ar/models.dart';

void main() {
  runApp(const CoolARApp());
}

class CoolARApp extends StatelessWidget {
  const CoolARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cool AR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ARDemoScreen(),
    );
  }
}

class ARDemoScreen extends StatefulWidget {
  const ARDemoScreen({super.key});

  @override
  State<ARDemoScreen> createState() => _ARDemoScreenState();
}

class _ARDemoScreenState extends State<ARDemoScreen> {
  final _session = ARSession();

  bool _sessionReady = false;
  ARTrackingState _trackingState = ARTrackingState.paused;
  String? _lastError;
  int _cubesPlaced = 0;

  StreamSubscription<AREvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub = _session.events.listen(_onAREvent);
  }

  void _onAREvent(AREvent event) {
    if (!mounted) return;
    setState(() {
      switch (event.type) {
        case AREventType.sessionReady:
          _sessionReady = true;
          _lastError = null;
        case AREventType.trackingStateChanged:
          _trackingState = event.trackingState ?? _trackingState;
        case AREventType.error:
          _lastError = event.errorMessage;
      }
    });
  }

  Future<void> _placeCube() async {
    try {
      await _session.placeObject(
        CubeConfig(
          color: _cubeColors[_cubesPlaced % _cubeColors.length],
          size: 0.1,
        ),
      );
      if (mounted) {
        setState(() {
          _cubesPlaced++;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _lastError = e.message;
        });
      }
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _session.dispose();
    super.dispose();
  }

  // Cycle through these colors for each placed cube.
  static const _cubeColors = [
    Color(0xFF4CAF50), // green
    Color(0xFF2196F3), // blue
    Color(0xFFF44336), // red
    Color(0xFFFF9800), // orange
    Color(0xFF9C27B0), // purple
    Color(0xFF00BCD4), // cyan
  ];

  String get _statusText {
    if (_lastError != null) return 'Error: $_lastError';
    if (!_sessionReady) return 'Starting AR session…';
    return switch (_trackingState) {
      ARTrackingState.tracking => 'Tap on a surface to place a cube',
      ARTrackingState.paused => 'Move your device to detect surfaces…',
      ARTrackingState.stopped => 'Tracking lost',
    };
  }

  Color get _statusColor {
    if (_lastError != null) return Colors.red;
    if (!_sessionReady) return Colors.orange;
    return switch (_trackingState) {
      ARTrackingState.tracking => Colors.green,
      ARTrackingState.paused => Colors.orange,
      ARTrackingState.stopped => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen AR view
          ARView(session: _session),

          // Status overlay (top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cube count (bottom left)
          if (_cubesPlaced > 0)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cubes: $_cubesPlaced',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),

          // Place cube button (bottom center)
          if (_sessionReady && _trackingState == ARTrackingState.tracking)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: _placeCube,
                  icon: const Icon(Icons.add_box_rounded),
                  label: const Text('Place Cube'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
