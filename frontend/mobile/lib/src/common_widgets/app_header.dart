import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/profile_page.dart';

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
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.idTokenChanges(),
            initialData: FirebaseAuth.instance.currentUser,
            builder: (context, snapshot) {
              final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
              if (user == null || user.isAnonymous) {
                return SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Get started'),
                  ),
                );
              }

              final hasAuthDisplayName =
                  (user.displayName ?? '').trim().isNotEmpty;
              if (hasAuthDisplayName) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_outline, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                );
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

                  if (!hasFirestoreUsername) {
                    return SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Get started'),
                      ),
                    );
                  }

                  return Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_outline, size: 22),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
