import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/home/presentation/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: PocketRoomApp()));
}

class PocketRoomApp extends StatelessWidget {
  const PocketRoomApp({super.key});

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
