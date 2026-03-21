import 'package:flutter/material.dart';
import '../../../common_widgets/responsive_layout.dart';
import 'widgets/get_started/get_started_desktop_layout.dart';
import 'widgets/get_started/get_started_mobile_layout.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 248, 221),
      body: ResponsiveLayout(
        mobile: GetStartedMobileLayout(),
        desktop: GetStartedDesktopLayout(),
      ),
    );
  }
}
