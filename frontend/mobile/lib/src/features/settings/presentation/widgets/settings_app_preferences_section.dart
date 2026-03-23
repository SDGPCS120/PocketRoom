import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';
import '../../../profile/presentation/widgets/profile/section_item.dart';
import 'settings_section_card.dart';
import 'settings_section_divider.dart';
import 'settings_section_toggle_item.dart';

class SettingsAppPreferencesSection extends ConsumerWidget {
  final String selectedLanguage;
  final VoidCallback onShowLanguagePicker;

  const SettingsAppPreferencesSection({
    super.key,
    required this.selectedLanguage,
    required this.onShowLanguagePicker,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return SettingsSectionCard(
      title: 'App Preferences',
      items: [
        SettingsSectionToggleItem(
          icon: isDarkMode ? Icons.dark_mode : Icons.dark_mode_outlined,
          label: 'Dark Mode',
          value: isDarkMode,
          onChanged: (val) {
            ref.read(themeModeProvider.notifier).state =
                val ? ThemeMode.dark : ThemeMode.light;
          },
        ),
        const SettingsSectionDivider(),
        SectionItem(
          icon: Icons.language_outlined,
          label: 'Language',
          value: selectedLanguage,
          trailingIcon: Icons.arrow_drop_down_rounded,
          onTap: onShowLanguagePicker,
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
