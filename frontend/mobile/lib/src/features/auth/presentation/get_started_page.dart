import 'package:flutter/material.dart';
import 'widgets/get_started/get_started_desktop_layout.dart';
import 'widgets/get_started/get_started_mobile_layout.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 248, 221),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 800;

          if (isDesktop) {
            return const GetStartedDesktopLayout();
          }
          return const GetStartedMobileLayout();
        },
      ),
    );
  }
}
