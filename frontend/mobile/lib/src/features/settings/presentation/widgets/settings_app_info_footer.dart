import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsAppInfoFooter extends StatelessWidget {
  const SettingsAppInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 6),
        Text(
          'Version 1.2.0 (Build 42)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
