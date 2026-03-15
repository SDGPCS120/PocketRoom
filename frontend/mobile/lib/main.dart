import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/splash/presentation/splash_page.dart';
import 'src/common_widgets/responsive_wrapper.dart';

void _logAuth(String message) {
  final line = '[AUTH_LOG] $message';
  debugPrint(line);
  developer.log(line, name: 'AuthFlow');
}

Future<void> _printCurrentAuthInfo(FirebaseAuth auth) async {
  final user = auth.currentUser;
  if (user == null) {
    _logAuth('No current Firebase user at startup');
    return;
  }

  final token = await user.getIdToken(true);
  if (token == null) {
    _logAuth('Token is null for uid=${user.uid}');
    return;
  }

  _logAuth('Startup user UID: ${user.uid}');
  _logAuth('Startup user isAnonymous: ${user.isAnonymous}');
  _logAuth('Startup user email: ${user.email ?? "(no email)"}');
  _logAuth('Startup TOKEN LENGTH: ${token.length}');
  const chunkSize = 800;
  for (int i = 0; i < token.length; i += chunkSize) {
    final end = (i + chunkSize < token.length) ? i + chunkSize : token.length;
    _logAuth('STARTUP_TOKEN_PART ${i ~/ chunkSize}: ${token.substring(i, end)}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously();
      _logAuth('Anonymous session started at app launch');
    } catch (e) {
      _logAuth('Anonymous sign-in failed at startup: $e');
    }
  }

  try {
    await _printCurrentAuthInfo(auth);
  } catch (e) {
    _logAuth('Failed to print startup auth info: $e');
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
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      builder: (context, child) => ResponsiveWrapper(child: child ?? const SizedBox.shrink()),
    );
  }
}
