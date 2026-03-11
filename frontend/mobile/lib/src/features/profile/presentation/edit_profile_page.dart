import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'John Doe',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'johndoe@gmail.com',
  );
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

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
        title: const Text(
          'Edit Profile',
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
            // ── Peach Avatar Card ─────────────────────────────────────────
            _AvatarCard(),

            // ── Form Fields ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  _FieldLabel('Full Name'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    hint: 'John Doe',
                  ),

                  const SizedBox(height: 20),

                  _FieldLabel('Email'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: 'johndoe@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  _FieldLabel('Phone Number'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  _FieldLabel('Address'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _addressController,
                    icon: Icons.home_outlined,
                    hint: 'Enter your address',
                  ),

                  const SizedBox(height: 36),

                  // ── Save Changes Button ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Frontend only — no backend call yet
                        Navigator.of(context).pop();
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
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar Card (Peach header with camera badge) ────────────────────────────────
class _AvatarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF4A264),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // Avatar with camera badge overlay
          Stack(
            clipBehavior: Clip.none,
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
              // Camera badge
              Positioned(
                bottom: 0,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4A264),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: Color(0xFF5C3D2E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Save Photo pill button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8845A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Save Photo',
              style: TextStyle(
                color: Color(0xFF2D1B0E),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field label ────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF2D2D2D),
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ── Input field ────────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D2D2D),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9E9E9E)),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
