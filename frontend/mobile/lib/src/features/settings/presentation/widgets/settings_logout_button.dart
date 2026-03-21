import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsLogoutButton extends StatelessWidget {
  final bool isLoggingOut;
  final VoidCallback onLogout;

  const SettingsLogoutButton({
    super.key,
    required this.isLoggingOut,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoggingOut ? null : onLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoggingOut
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textPrimary,
                  ),
                ),
              )
            : const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
