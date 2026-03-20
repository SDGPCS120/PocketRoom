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
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SettingsLanguagePicker(currentLanguage: currentLanguage),
    );
  }

  @override
  Widget build(BuildContext context) {
    const languages = ['English', 'Sinhala', 'Tamil'];
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        color: selected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
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
