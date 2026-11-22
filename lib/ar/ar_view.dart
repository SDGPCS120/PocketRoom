import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'ar_session.dart';

/// A widget that hosts the native AR camera view.
///
/// On Android, this embeds an `ArSceneView` via Hybrid Composition.
/// On iOS (future), this would use `UiKitView` with an ARKit scene.
///
/// The AR session starts automatically when this widget is mounted.
/// Listen to [ARSession.events] for session readiness and tracking state.
class ARView extends StatefulWidget {
  /// The [ARSession] that manages communication with the native AR engine.
  final ARSession session;

  /// Called when the native platform view is created.
  final VoidCallback? onViewCreated;

  const ARView({
    super.key,
    required this.session,
    this.onViewCreated,
  });

  @override
  State<ARView> createState() => _ARViewState();
}

class _ARViewState extends State<ARView> {
  static const String _viewType = 'cool_ar/ar_view';

  @override
  void initState() {
    super.initState();
    // Start listening to native events as soon as the view is mounted.
    widget.session.startListening();
  }

  @override
  void dispose() {
    // Session disposal is handled by the parent that owns the ARSession.
    // We do NOT call widget.session.dispose() here because the parent
    // controls the session lifecycle.
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    widget.onViewCreated?.call();
  }

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          // Accept all gestures so taps pass through to the native AR view.
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        );
      case TargetPlatform.iOS:
        // Future: return UiKitView(viewType: _viewType, ...)
        return const Center(
          child: Text('ARKit support coming soon'),
        );
      default:
        return const Center(
          child: Text('AR is not supported on this platform'),
        );
    }
  }
}
