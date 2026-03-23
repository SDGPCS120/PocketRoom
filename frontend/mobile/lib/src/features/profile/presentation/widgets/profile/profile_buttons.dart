import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ProfilePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ProfilePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.primaryButton(context),
        child: Text(label, style: AppTextStyles.buttonText(context)),
      ),
    );
  }
}

class ProfileOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ProfileOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: AppButtonStyles.outlinedButton(context),
        child: Text(label, style: AppTextStyles.buttonText(context)),
      ),
    );
  }
}
