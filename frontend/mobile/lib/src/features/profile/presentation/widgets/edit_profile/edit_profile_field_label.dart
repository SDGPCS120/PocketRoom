import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class EditProfileFieldLabel extends StatelessWidget {
  final String text;
  const EditProfileFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
