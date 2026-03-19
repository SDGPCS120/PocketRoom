import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CircularNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircularNavButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 0.5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.cardBorder.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
