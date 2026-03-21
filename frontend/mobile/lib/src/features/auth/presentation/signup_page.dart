import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../common_widgets/responsive_layout.dart';
import 'widgets/signup/signup_form.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: ResponsiveLayout.auth(
        content: const SignupForm(),
      ),
    );
  }
}
