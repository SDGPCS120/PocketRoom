import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CartQuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const CartQuantityButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
