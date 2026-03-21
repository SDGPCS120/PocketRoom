import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsAppInfoFooter extends StatelessWidget {
  const SettingsAppInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          'Version 1.2.0 (Build 42)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
