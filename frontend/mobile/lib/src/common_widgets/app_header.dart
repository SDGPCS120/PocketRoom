import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

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

                  try {
                    if (auth.currentUser == null) {
                      await auth.signInAnonymously();
                      print("Signed in anonymously");
                    }

                    final user = auth.currentUser;
                    if (user == null) {
                      print("User is still null.");
                      return;
                    }

                    final token = await user.getIdToken(true);

                    if (token == null) {
                      print("Token is null.");
                      return;
                    }

                    print("UID: ${user.uid}");
                    print("TOKEN LENGTH: ${token.length}");

                    // Print in chunks to avoid console truncation
                    const chunkSize = 800;
                    for (int i = 0; i < token.length; i += chunkSize) {
                      final end = (i + chunkSize < token.length)
                          ? i + chunkSize
                          : token.length;
                      print(
                        "TOKEN_PART ${i ~/ chunkSize}: ${token.substring(i, end)}",
                      );
                    }
                  } catch (e) {
                    print("Auth error: $e");
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
