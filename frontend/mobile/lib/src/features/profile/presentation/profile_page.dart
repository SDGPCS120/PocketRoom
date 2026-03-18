import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:pocketroom/src/features/cart/presentation/cart_page.dart';
import 'package:pocketroom/src/features/auth/presentation/get_started_page.dart';
import 'package:pocketroom/src/core/api_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/presentation/settings_page.dart';
import 'edit_profile_page.dart';
import 'widgets/section_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _UserData {
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String role = 'customer';
}

class _ProfilePageState extends State<ProfilePage> {
  final _user = _UserData();
  bool _isLoading = true;
  bool _isAnonymousUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _isAnonymousUser = user.isAnonymous;
    _user.email = user.email ?? '';
    _user.name = (user.displayName ?? '').trim();
    _user.role = _isAnonymousUser ? 'anonymous' : 'customer';

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = snapshot.data();
      if (data != null) {
        final username = (data['username'] as String? ?? '').trim();
        final phone = (data['phone'] as String? ?? '').trim();
        final address = (data['address'] as String? ?? '').trim();
        final role = (data['role'] as String? ?? '').trim();

        if (username.isNotEmpty) {
          _user.name = username;
        }
        _user.phone = phone;
        _user.address = address;
        if (role.isNotEmpty) {
          _user.role = role;
        }
      }
    } catch (_) {
      // Keep Firebase Auth fallback values when Firestore is unavailable.
    }

    if (_user.name.isEmpty) {
      if (_user.email.isNotEmpty && _user.email.contains('@')) {
        _user.name = _user.email.split('@').first;
      } else {
        _user.name = 'Profile';
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: _user.name,
          initialEmail: _user.email,
          initialPhone: _user.phone,
          initialAddress: _user.address,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _user.name = (result['name'] as String?) ?? _user.name;
        _user.email = (result['email'] as String?) ?? _user.email;
        _user.phone = (result['phone'] as String?) ?? _user.phone;
        _user.address = (result['address'] as String?) ?? _user.address;
      });
    }
  }

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInAnonymously();

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showCartDebugJson() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No signed-in user found.')),
      );
      return;
    }

    try {
      final token = await user.getIdToken(true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart-debug/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Request failed with status ${response.statusCode}');
      }

      final parsed = jsonDecode(response.body);
      final prettyJson = const JsonEncoder.withIndent('  ').convert(parsed);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cart Debug JSON'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: SelectableText(
                  prettyJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart debug JSON: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
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
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ProfileHeaderCard(
              name: _user.name,
              email: _user.email,
              onEditProfile: _openEditProfile,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: LinearProgressIndicator(),
                    ),
                  _SectionCard(
                    title: 'Personal Information',
                    items: [
                      SectionItem(
                        icon: Icons.badge_outlined,
                        label: 'Role',
                        value: _user.role,
                        onTap: () {},
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: _user.email.isEmpty ? 'Add email' : _user.email,
                        onTap: _openEditProfile,
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: _user.phone.isEmpty
                            ? 'Add phone number'
                            : _user.phone,
                        onTap: _openEditProfile,
                      ),
                      _Divider(),
                      SectionItem(
                        icon: Icons.home_outlined,
                        label: 'Address',
                        value: _user.address.isEmpty
                            ? 'Add address'
                            : _user.address,
                        onTap: _openEditProfile,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        label: 'My Orders',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CartPage(),
                            ),
                          );
                        },
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
                  if (_isAnonymousUser) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GetStartedPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _showCartDebugJson,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'View Cart Debug JSON',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onEditProfile;

  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
              GestureDetector(
                onTap: onEditProfile,
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF2D1B0E),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email.isEmpty ? 'No email on file' : email,
                style: const TextStyle(
                  color: Color(0xFF5C3D2E),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onEditProfile,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
