import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  void _logLine(String message) {
    final line = '[AUTH_LOG] $message';
    debugPrint(line);
    developer.log(line, name: 'AuthFlow');
    stdout.writeln(line);
  }

  Future<void> _printGoogleAuthInfo(User user) async {
    _logLine('=== GOOGLE LOGIN SUCCESS ===');
    final token = await user.getIdToken(true);
    if (token == null) {
      _logLine('Google token is null for uid=${user.uid}');
      return;
    }

    _logLine('Google UID: ${user.uid}');
    _logLine('Google Email: ${user.email ?? "(no email)"}');
    _logLine('Google TOKEN LENGTH: ${token.length}');

    const chunkSize = 600;
    for (int i = 0; i < token.length; i += chunkSize) {
      final end = (i + chunkSize < token.length) ? i + chunkSize : token.length;
      _logLine('GOOGLE_TOKEN_PART ${i ~/ chunkSize}: ${token.substring(i, end)}');
    }
    _logLine('=== END GOOGLE TOKEN ===');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 40),
          Row(
            children: [
              //CART BUTTON
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Use centralized color
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 4),

              //PROFILE BUTTON
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Use centralized color
                  shape: const CircleBorder(),
                ),
              ),

              // TEMP AUTH BUTTON
              IconButton(
                onPressed: () async {
                  final auth = FirebaseAuth.instance;
                  final googleSignIn = GoogleSignIn();
                  _logLine('Starting Google sign-in...');

                  try {
                    final googleUser = await googleSignIn.signIn();
                    if (googleUser == null) {
                      _logLine('Google sign-in cancelled by user');
                      return;
                    }

                    final googleAuth = await googleUser.authentication;
                    final credential = GoogleAuthProvider.credential(
                      accessToken: googleAuth.accessToken,
                      idToken: googleAuth.idToken,
                    );

                    UserCredential userCredential;
                    final currentUser = auth.currentUser;

                    // Preserve anonymous UID/data by linking when possible.
                    if (currentUser != null && currentUser.isAnonymous) {
                      userCredential =
                          await currentUser.linkWithCredential(credential);
                    } else {
                      userCredential =
                          await auth.signInWithCredential(credential);
                    }

                    final user = userCredential.user;
                    if (user == null) {
                      _logLine('Google sign-in succeeded but user is null');
                      return;
                    }

                    await _printGoogleAuthInfo(user);
                  } on FirebaseAuthException catch (e) {
                    // If linking fails due to account already existing, fallback to sign in.
                    if (e.code == 'credential-already-in-use' ||
                        e.code == 'provider-already-linked') {
                      try {
                        final googleUser = await googleSignIn.signIn();
                        if (googleUser == null) return;
                        final googleAuth = await googleUser.authentication;
                        final credential = GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );
                        final userCredential =
                            await auth.signInWithCredential(credential);
                        final user = userCredential.user;
                        if (user == null) {
                          _logLine('Fallback Google sign-in returned null user');
                          return;
                        }
                        await _printGoogleAuthInfo(user);
                      } catch (fallbackError) {
                        _logLine('Fallback Google sign-in failed: $fallbackError');
                      }
                    } else {
                      _logLine('Firebase auth error: ${e.code} - ${e.message}');
                    }
                  } catch (e) {
                    _logLine('Auth error: $e');
                  }
                },

                icon: const Icon(Icons.verified_user, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 220, 107, 26),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
