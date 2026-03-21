import 'package:flutter/material.dart';
import '../../../profile/presentation/widgets/profile/section_item.dart';
import 'settings_section_card.dart';
import 'settings_section_divider.dart';
import 'settings_section_toggle_item.dart';

class SettingsAppPreferencesSection extends StatefulWidget {
  final String selectedLanguage;
  final VoidCallback onShowLanguagePicker;

  const SettingsAppPreferencesSection({
    super.key,
    required this.selectedLanguage,
    required this.onShowLanguagePicker,
  });

  @override
  State<SettingsAppPreferencesSection> createState() =>
      _SettingsAppPreferencesSectionState();
}

class _SettingsAppPreferencesSectionState
    extends State<SettingsAppPreferencesSection> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'App Preferences',
      items: [
        SettingsSectionToggleItem(
          icon: Icons.dark_mode_outlined,
          label: 'Dark Mode',
          value: _isDarkMode,
          onChanged: (val) {
            setState(() {
              _isDarkMode = val;
            });
          },
        ),
        const SettingsSectionDivider(),
        SectionItem(
          icon: Icons.language_outlined,
          label: 'Language',
          value: widget.selectedLanguage,
          trailingIcon: Icons.arrow_drop_down_rounded,
          onTap: widget.onShowLanguagePicker,
        ),
        const SettingsSectionDivider(),
        SectionItem(
          icon: Icons.square_foot_outlined,
          label: 'Measurement Units',
          value: 'Imperial (in, ft)',
          onTap: () {},
        ),
      ],
    );
  }
}
