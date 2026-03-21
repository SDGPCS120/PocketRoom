import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/home/presentation/main_screen.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_app_bar.dart';
import 'widgets/settings_app_preferences_section.dart';
import 'widgets/settings_language_picker.dart';
import 'widgets/settings_notifications_section.dart';
import 'widgets/settings_privacy_section.dart';
import 'widgets/settings_support_section.dart';
import 'widgets/settings_legal_section.dart';
import 'widgets/settings_logout_button.dart';
import 'widgets/settings_app_info_footer.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(settingsProvider.notifier).logout();
    if (success && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              SettingsAppPreferencesSection(
                selectedLanguage: state.selectedLanguage,
                onShowLanguagePicker: () => SettingsLanguagePicker.show(
                  context,
                  state.selectedLanguage,
                ),
              ),
              const SizedBox(height: 20),
              SettingsNotificationsSection(
                pushNotifications: state.pushNotifications,
                orderUpdates: state.orderUpdates,
                onPushNotificationsChanged: notifier.togglePushNotifications,
                onOrderUpdatesChanged: notifier.toggleOrderUpdates,
              ),
              const SizedBox(height: 20),
              const SettingsPrivacySection(),
              const SizedBox(height: 20),
              SettingsSupportSection(
                onLaunchPocketRoom: notifier.launchPocketRoom,
              ),
              const SizedBox(height: 20),
              const SettingsLegalSection(),
              const SizedBox(height: 28),
              SettingsLogoutButton(
                isLoggingOut: state.isLoggingOut,
                onLogout: () => _handleLogout(context, ref),
              ),
              const SizedBox(height: 28),
              const SettingsAppInfoFooter(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
