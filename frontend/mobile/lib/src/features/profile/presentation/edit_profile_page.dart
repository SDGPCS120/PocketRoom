import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/edit_profile/edit_profile_app_bar.dart';
import 'widgets/edit_profile/edit_profile_avatar_card.dart';
import 'widgets/edit_profile/edit_profile_field_label.dart';
import 'widgets/edit_profile/edit_profile_input_field.dart';

class EditProfilePage extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialAddress;

  const EditProfilePage({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialAddress,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? 'John Doe';
    _emailController.text = widget.initialEmail ?? 'johndoe@gmail.com';
    _phoneController.text = widget.initialPhone ?? '';
    _addressController.text = widget.initialAddress ?? '';
  }

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const EditProfileAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Peach Avatar Card ─────────────────────────────────────────
            const EditProfileAvatarCard(),

            // ── Form Fields ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  const EditProfileFieldLabel('Full Name'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    hint: 'John Doe',
                  ),

                  const SizedBox(height: 20),

                  const EditProfileFieldLabel('Email'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: 'johndoe@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  const EditProfileFieldLabel('Phone Number'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 20),

                  const EditProfileFieldLabel('Address'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
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
                        // Frontend only — return updated values to caller
                        Navigator.of(context).pop({
                          'name': _nameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'address': _addressController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
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
