import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../common_widgets/responsive_layout.dart';
import 'widgets/signup/signup_form.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: ResponsiveLayout.auth(
        content: const SignupForm(),
      ),
    );
  }
}
