import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsSectionToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSectionToggleItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.background,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: AppColors.background,
            inactiveTrackColor: AppColors.textSecondary.withValues(alpha: 0.3),
            trackOutlineColor: WidgetStateProperty.all(
              Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
