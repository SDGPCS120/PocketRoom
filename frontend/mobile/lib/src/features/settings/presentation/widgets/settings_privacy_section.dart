import 'package:flutter/material.dart';
import '../../../profile/presentation/widgets/profile/section_item.dart';
import '../login_sessions_page.dart';
import 'settings_section_card.dart';
import 'settings_section_divider.dart';

class SettingsPrivacySection extends StatelessWidget {
  const SettingsPrivacySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Privacy & Security',
      items: [
        SectionItem(
          icon: Icons.devices_outlined,
          label: 'Login Sessions',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginSessionsPage())),
        ),
        const SettingsSectionDivider(),
        SectionItem(
          icon: Icons.person_remove_outlined,
          label: 'Delete Account',
          isDestructive: true,
          onTap: () {},
        ),
      ],
    );
  }
}
