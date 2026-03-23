import 'package:flutter/material.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';
import '../../../common_widgets/responsive_layout.dart';
import 'widgets/login/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
        content: const LoginForm(),
      ),
    );
  }
}
