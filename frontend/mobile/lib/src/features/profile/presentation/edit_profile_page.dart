import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/profile_provider.dart';
import 'widgets/edit_profile/edit_profile_app_bar.dart';
import 'widgets/edit_profile/edit_profile_avatar_card.dart';
import 'widgets/edit_profile/edit_profile_field_label.dart';
import 'widgets/edit_profile/edit_profile_input_field.dart';

class EditProfilePage extends ConsumerStatefulWidget {
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
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _saving = false;

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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveChanges() async {
    if (_saving) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(profileProvider.notifier)
          .saveUserData(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            address: _addressController.text,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
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
            const EditProfileAvatarCard(),
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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _saving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (_saving) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Saving your profile...',
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
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
