import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/home/presentation/home_page.dart';
import 'src/features/auth/presentation/username_page.dart';
import 'src/features/splash/presentation/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void _logAuth(String message) {
  final line = '[AUTH_LOG] $message';
  debugPrint(line);
  developer.log(line, name: 'AuthFlow');
  stdout.writeln(line);
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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.idTokenChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        if (user == null || user.isAnonymous) {
          return const HomePage();
        }

        final hasAuthDisplayName = (user.displayName ?? '').trim().isNotEmpty;
        if (hasAuthDisplayName) {
          return const HomePage();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userDocSnapshot) {
            final docData = userDocSnapshot.data?.data();
            final firestoreUsername =
                (docData?['username'] as String? ?? '').trim();
            final hasFirestoreUsername = firestoreUsername.isNotEmpty;

            if (hasFirestoreUsername) {
              return const HomePage();
            }

            if (userDocSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return const UsernamePage();
          },
        );
      },
    );
  }
}
