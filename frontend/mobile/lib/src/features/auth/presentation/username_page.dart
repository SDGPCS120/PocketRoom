import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/username/username_form.dart';

class UsernamePage extends StatelessWidget {
  const UsernamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Enter username', style: TextStyle(color: AppColors.textPrimary)),
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: const SafeArea(
          child: UsernameForm(),
        ),
      ),
    );
  }
}
