import 'package:flutter/material.dart';

/// A widget that switches between mobile and desktop layouts based on screen width.
class ResponsiveLayout extends StatelessWidget {
  /// The layout to display on mobile devices.
  final Widget mobile;

  /// The layout to display on desktop/larger screens.
  final Widget desktop;

  /// The screen width breakpoint to switch between layouts.
  final double breakpoint;

  /// Whether to wrap the desktop layout in a centered white card with shadows.
  /// Useful for authentication and settings pages.
  final bool useCardOnDesktop;

  /// The maximum width of the centered card on desktop.
  final double maxDesktopWidth;

  /// Whether to automatically wrap the mobile layout in a SafeArea.
  final bool useSafeAreaOnMobile;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
    this.breakpoint = 800.0,
    this.useCardOnDesktop = false,
    this.maxDesktopWidth = 480.0,
    this.useSafeAreaOnMobile = true,
  });

  /// Factory constructor for a centered card layout commonly used in auth pages.
  factory ResponsiveLayout.auth({
    required Widget content,
    double maxWidth = 480.0,
  }) {
    return ResponsiveLayout(
      mobile: content,
      desktop: content,
      useCardOnDesktop: true,
      maxDesktopWidth: maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > breakpoint;

        if (!isDesktop) {
          return useSafeAreaOnMobile ? SafeArea(child: mobile) : mobile;
        }

        if (useCardOnDesktop) {
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxDesktopWidth),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: desktop,
            ),
          );
        }

        return desktop;
      },
    );
  }
}
