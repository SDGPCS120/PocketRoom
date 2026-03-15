import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A wrapper that centers and constrains the app width on desktop browsers.
/// On mobile devices, it returns the child unchanged.
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    // Let the web app expand to fill the available screen width instead of 
    // constraining it to a max width.
    return Material(
      color: Colors.white,
      child: child,
    );
  }
}
