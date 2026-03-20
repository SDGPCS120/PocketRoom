import 'package:flutter/material.dart';
import 'section_item.dart';
import 'profile_section_card.dart';
import 'profile_section_divider.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Settings & Support',
      items: [
        SectionItem(
          icon: Icons.tune_rounded,
          label: 'Advanced Settings',
          onTap: () {},
        ),
        const ProfileSectionDivider(),
        SectionItem(
          icon: Icons.help_outline_rounded,
          label: 'Help Center',
          onTap: () {},
        ),
      ],
    );
  }
}
