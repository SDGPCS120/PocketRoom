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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.surface,
            activeTrackColor: colorScheme.primary,
            inactiveThumbColor: colorScheme.surface,
            inactiveTrackColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            trackOutlineColor: WidgetStateProperty.all(
              Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
