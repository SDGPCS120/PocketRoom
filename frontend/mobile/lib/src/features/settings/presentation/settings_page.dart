import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/home/presentation/main_screen.dart';
import '../../profile/presentation/widgets/section_item.dart';
import 'licenses_page.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Mock states for toggles
  bool _pushNotifications = true;
  bool _orderUpdates = true;

  String _selectedLanguage = 'English';
  static const _languages = ['English', 'Sinhala', 'Tamil'];

  Future<void> _launchPocketRoom() async {
    final uri = Uri.parse('https://www.pocketroom.lk');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInAnonymously();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false, // remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _SectionCard(
                title: 'App Preferences',
                items: [
                  _SectionToggleItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state =
                          val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                  _Divider(),
                  SectionItem(
                    icon: Icons.language_outlined,
                    label: 'Language',
                    value: _selectedLanguage,
                    trailingIcon: Icons.arrow_drop_down_rounded,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.background,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Language',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ..._languages.map((lang) {
                                    final selected =
                                        lang == _selectedLanguage;
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        lang,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: selected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      trailing: selected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: AppColors.primary,
                                              size: 20,
                                            )
                                          : null,
                                      onTap: () {
                                        setState(
                                          () => _selectedLanguage = lang,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  _Divider(),
                  SectionItem(
                    icon: Icons.square_foot_outlined,
                    label: 'Measurement Units',
                    value: 'Imperial (in, ft)',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Notifications',
                items: [
                  _SectionToggleItem(
                    icon: Icons.notifications_active_outlined,
                    label: 'Push Notifications',
                    value: _pushNotifications,
                    onChanged: (val) {
                      setState(() => _pushNotifications = val);
                    },
                  ),
                  _Divider(),
                  _SectionToggleItem(
                    icon: Icons.local_shipping_outlined,
                    label: 'Order Updates',
                    value: _orderUpdates,
                    onChanged: (val) {
                      setState(() => _orderUpdates = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Privacy & Security',
                items: [
                  SectionItem(
                    icon: Icons.devices_outlined,
                    label: 'Login Sessions',
                    onTap: () {},
                  ),
                  _Divider(),
                  SectionItem(
                    icon: Icons.person_remove_outlined,
                    label: 'Delete Account',
                    isDestructive: true,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Support',
                items: [
                  SectionItem(
                    icon: Icons.feedback_outlined,
                    label: 'Feedback',
                    onTap: _launchPocketRoom,
                  ),
                  _Divider(),
                  SectionItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help',
                    onTap: _launchPocketRoom,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Legal',
                items: [
                  SectionItem(
                    icon: Icons.policy_outlined,
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      );
                    },
                  ),
                  _Divider(),
                  SectionItem(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServicePage(),
                        ),
                      );
                    },
                  ),
                  _Divider(),
                  SectionItem(
                    icon: Icons.gavel_outlined,
                    label: 'Licenses',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LicensesPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Logout button — matches Profile page style exactly
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
              const SizedBox(height: 28),
              // App Info — subtle, bottom-anchored version label
              const _AppInfoFooter(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
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

class _AppInfoFooter extends StatelessWidget {
  const _AppInfoFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: Color(0xFFBDBDBD),
        ),
        SizedBox(width: 6),
        Text(
          'Version 1.2.0 (Build 42)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFBDBDBD),
          ),
        ),
      ],
    );
  }
}

class _SectionToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SectionToggleItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF9E9E9E),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4CAE4F),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE0E0E0),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
