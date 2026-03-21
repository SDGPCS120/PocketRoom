import 'package:flutter/material.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';
import '../../../common_widgets/responsive_layout.dart';
import 'widgets/login/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
        content: const LoginForm(),
      ),
    );
  }
}
