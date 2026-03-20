import 'package:flutter/material.dart';
import '../../../profile/presentation/widgets/profile/section_item.dart';
import 'settings_section_card.dart';
import 'settings_section_divider.dart';

class SettingsSupportSection extends StatelessWidget {
  final VoidCallback onLaunchPocketRoom;

  const SettingsSupportSection({super.key, required this.onLaunchPocketRoom});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Support',
      items: [
        SectionItem(
          icon: Icons.feedback_outlined,
          label: 'Feedback',
          onTap: onLaunchPocketRoom,
        ),
        const SettingsSectionDivider(),
        SectionItem(
          icon: Icons.help_outline_rounded,
          label: 'Help',
          onTap: onLaunchPocketRoom,
        ),
      ],
    );
  }
}
