import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/get_started_page.dart';
import '../features/auth/presentation/profile_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/cart/data/cart_provider.dart';
import 'package:pocketroom/src/features/cart/presentation/cart_page.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  // This renders the top header and switches actions by auth/onboarding state.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final itemCount = cartItems.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Image.asset('assets/logo.png', height: 40),
          ),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.idTokenChanges(),
            initialData: FirebaseAuth.instance.currentUser,
            builder: (context, snapshot) {
              final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
              // Anonymous users see a CTA to start auth.
              if (user == null || user.isAnonymous) {
                return SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GetStartedPage(),
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
              final usernameAllowedRegex = RegExp(r'^[a-z0-9_]+$');

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, userDocSnapshot) {
                  final docData = userDocSnapshot.data?.data();
                  final firestoreUsername =
                      (docData?['username'] as String? ?? '').trim();
                  final hasFirestoreUsername = firestoreUsername.isNotEmpty &&
                      usernameAllowedRegex.hasMatch(
                        firestoreUsername.toLowerCase(),
                      );

                  // If onboarding is still incomplete, keep showing the CTA.
                  if (!hasFirestoreUsername) {
                    return SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GetStartedPage(),
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

                  return _buildUserActions(context, ref, itemCount);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserActions(BuildContext context, WidgetRef ref, int itemCount) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 22),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: const CircleBorder(),
              ),
            ),
            if (itemCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    itemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
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
}
