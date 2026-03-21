import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/auth/presentation/get_started_page.dart';
import '../../../core/theme/app_theme.dart';
import '../../../common_widgets/responsive_layout.dart';
import 'edit_profile_page.dart';
import 'providers/profile_provider.dart';

import 'widgets/profile/profile_header_card.dart';
import 'widgets/profile/profile_app_bar.dart';
import 'widgets/profile/profile_personal_info_section.dart';
import 'widgets/profile/profile_activity_section.dart';
import 'widgets/profile/profile_settings_section.dart';
import 'widgets/profile/profile_buttons.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _openEditProfile(BuildContext context, WidgetRef ref) async {
    final state = ref.read(profileProvider);
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: state.name,
          initialEmail: state.email,
          initialPhone: state.phone,
          initialAddress: state.address,
        ),
      ),
    );

    if (result != null) {
      ref.read(profileProvider.notifier).updateUserData(
            name: result['name'] as String?,
            email: result['email'] as String?,
            phone: result['phone'] as String?,
            address: result['address'] as String?,
          );
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(profileProvider.notifier).logout();
    if (success && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _showCartDebugJson(BuildContext context, WidgetRef ref) async {
    try {
      final jsonStr = await ref.read(profileProvider.notifier).fetchCartDebugJson();
      if (jsonStr == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No signed-in user found.')),
        );
        return;
      }
      
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cart Debug JSON'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart debug JSON: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileHeaderCard(
            name: state.name,
            email: state.email,
            onEditProfile: () => _openEditProfile(context, ref),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: LinearProgressIndicator(),
                  ),
                ProfilePersonalInfoSection(
                  role: state.role,
                  email: state.email,
                  phone: state.phone,
                  address: state.address,
                  onEditProfile: () => _openEditProfile(context, ref),
                ),
                const SizedBox(height: 20),
                const ProfileActivitySection(),
                const SizedBox(height: 20),
                const ProfileSettingsSection(),
                if (state.isAnonymousUser) ...[
                  const SizedBox(height: 20),
                  ProfilePrimaryButton(
                    label: 'Get Started',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GetStartedPage(),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
                ProfileOutlinedButton(
                  label: 'Log out', 
                  onPressed: () => _handleLogout(context, ref)
                ),
                const SizedBox(height: 12),
                ProfileOutlinedButton(
                  label: 'View Cart Debug JSON',
                  onPressed: () => _showCartDebugJson(context, ref),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const ProfileAppBar(),
      body: ResponsiveLayout(
        mobile: content,
        desktop: content,
        useCardOnDesktop: true,
        maxDesktopWidth: 600, // Slightly wider for profile
      ),
    );
  }
}
