import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

class SettingsLanguagePicker extends StatelessWidget {
  final String currentLanguage;

  const SettingsLanguagePicker({
    super.key,
    required this.currentLanguage,
  });

  static void show(BuildContext context, String currentLanguage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SettingsLanguagePicker(currentLanguage: currentLanguage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const languages = ['English', 'Sinhala', 'Tamil'];
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...languages.map((lang) {
              final selected = lang == currentLanguage;
              return Consumer(
                builder: (context, ref, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      lang,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_rounded, color: colorScheme.primary, size: 20)
                        : null,
                    onTap: () {
                      ref.read(settingsProvider.notifier).setLanguage(lang);
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
