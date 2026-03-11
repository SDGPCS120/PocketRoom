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

    return Material(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return child;
          }

          return Container(
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
