import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/home/presentation/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> _printAnonymousAuthInfo(FirebaseAuth auth) async {
  final user = auth.currentUser;
  if (user == null || !user.isAnonymous) {
    return;
  }

  final token = await user.getIdToken(true);
  if (token == null) {
    debugPrint('Anonymous token is null for uid=${user.uid}');
    return;
  }

  debugPrint('Anonymous UID: ${user.uid}');
  debugPrint('Anonymous TOKEN LENGTH: ${token.length}');

  const chunkSize = 800;
  for (int i = 0; i < token.length; i += chunkSize) {
    final end = (i + chunkSize < token.length) ? i + chunkSize : token.length;
    debugPrint('ANON_TOKEN_PART ${i ~/ chunkSize}: ${token.substring(i, end)}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
      debugPrint('Anonymous session started at app launch');
    } catch (e) {
      debugPrint('Anonymous sign-in failed at startup: $e');
    }
  }

  try {
    await _printAnonymousAuthInfo(auth);
  } catch (e) {
    debugPrint('Failed to print anonymous auth info: $e');
  }

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
