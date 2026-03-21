import 'package:flutter/material.dart';
import 'package:pocketroom/src/features/home/presentation/main_screen.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';
import 'widgets/animated_splash_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedSplashLogo(
          onAnimationComplete: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
      ),
    );
  }
}
