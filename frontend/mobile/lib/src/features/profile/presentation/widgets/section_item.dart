import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SectionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;
  /// When non-null, replaces the trailing chevron with this value text.
  final String? value;
  /// Optional icon shown after the value text (e.g. a dropdown arrow).
  final IconData? trailingIcon;

  const SectionItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
    this.value,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isDestructive
        ? Colors.redAccent
        : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            // Left icon - plain icon with grey color (matches design)
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.redAccent : const Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: itemColor,
                ),
              ),
            ),
            // Value text OR chevron — mutually exclusive
            if (value != null) ...[  
              Text(
                value!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              if (trailingIcon != null) ...[  
                const SizedBox(width: 4),
                Icon(
                  trailingIcon,
                  size: 16,
                  color: const Color(0xFF9E9E9E),
                ),
              ],
            ] else
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF9E9E9E),
              ),
          ],
        ),
      ),
    );
  }
}
