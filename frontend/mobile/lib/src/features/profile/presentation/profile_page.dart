import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'edit_profile_page.dart';
import 'widgets/section_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Peach Header Card ────────────────────────────────────────
            _ProfileHeaderCard(),

            // ── Body Content ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // ── Personal Information Card ──────────────────────────
                  _SectionCard(
                    title: 'Personal Information',
                    items: [
                      SectionItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () {},
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        onTap: () {},
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.home_outlined,
                        label: 'Address',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── My Activity Card ───────────────────────────────────
                  _SectionCard(
                    title: 'My Activity',
                    items: [
                      SectionItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        onTap: () {},
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.shopping_cart_outlined,
                        label: 'My Cart',
                        onTap: () {},
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.bookmark_border_rounded,
                        label: 'Reviews & Ratings',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Settings & Support Card ────────────────────────────
                  _SectionCard(
                    title: 'Settings & Support',
                    items: [
                      SectionItem(
                        icon: Icons.tune_rounded,
                        label: 'Advanced Settings',
                        onTap: () {},
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header Card (Peach background with avatar) ─────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Peach background card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 24,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF4A264),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              // Avatar circle
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8D5C4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 56,
                  color: Color(0xFF4A3728),
                ),
              ),

              const SizedBox(height: 14),

              // Name
              const Text(
                'John Doe',
                style: TextStyle(
                  color: Color(0xFF2D1B0E),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              const Text(
                'johndoe@gmail.com',
                style: TextStyle(
                  color: Color(0xFF5C3D2E),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 10),

              // Edit Profile
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                },
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Color(0xFFD45C00),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Camera icon (top-right of the card)
        Positioned(
          top: 12,
          right: 28,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.photo_camera_outlined,
              size: 26,
              color: Color(0xFF5C3D2E),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Card ───────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title above the card
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2D2D2D),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Light grey card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }
}

// ── Inner divider ──────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.withValues(alpha: 0.25),
    );
  }
}
