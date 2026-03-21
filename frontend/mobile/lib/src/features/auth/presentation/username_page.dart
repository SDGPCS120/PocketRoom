import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/username/username_form.dart';

class UsernamePage extends StatelessWidget {
  const UsernamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          title: Text('Enter username', style: TextStyle(color: colorScheme.onSurface)),
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
