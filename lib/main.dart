import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/home/presentation/home_page.dart';

void main() {
  runApp(const ProviderScope(child: PocketRoomApp()));
}

class PocketRoomApp extends StatelessWidget {
  const PocketRoomApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketRoom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Using the new centralized theme
      home: const HomePage(),
    );
  }
}
