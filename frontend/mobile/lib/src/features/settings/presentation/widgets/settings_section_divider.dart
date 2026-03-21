import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsSectionDivider extends StatelessWidget {
  const SettingsSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.textSecondary.withValues(alpha: 0.25),
    );
  }
}
