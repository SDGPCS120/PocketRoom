import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/get_started_page.dart';
import '../features/profile/presentation/profile_page.dart'; // <-- Using Dev's new path
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/cart/data/cart_provider.dart';
import 'package:pocketroom/src/features/cart/presentation/cart_page.dart';
import 'package:pocketroom/src/features/home/data/providers.dart';

class AppHeader extends ConsumerStatefulWidget {
  const AppHeader({super.key});

  @override
  ConsumerState<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<AppHeader> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // It's safe to read the provider in initState
    _searchController = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch cart state
    final cartItems = ref.watch(cartProvider);
    final itemCount = cartItems.length;

    // Watch search query
    final currentQuery = ref.watch(searchQueryProvider);

    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. keep product-details' clickable logo
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Image.asset('assets/logo.png', height: 40),
          ),
          // 2. keep Dev's / our websafe layout logic!
          // --- BEGIN OUR WEBSAFE LAYOUT ---
          if (isDesktop)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search furniture...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: currentQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFE5D3),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
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
          // --- END THE WEBSAFE LAYOUT ---
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
