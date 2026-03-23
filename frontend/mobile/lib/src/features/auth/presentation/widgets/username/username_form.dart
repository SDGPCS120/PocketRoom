import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth_text_field.dart';

class UsernameForm extends ConsumerStatefulWidget {
  const UsernameForm({super.key});

  @override
  ConsumerState<UsernameForm> createState() => _UsernameFormState();
}

class _UsernameFormState extends ConsumerState<UsernameForm> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authController = ref.read(authControllerProvider);
    final currentName = authController.auth.currentUser?.displayName ?? '';
    _controller.text = currentName;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _saveUsername() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider).reserveUsername(_controller.text);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('StateError: ', '');
      if (msg == 'USERNAME_TAKEN') {
        _showMessage('That username is already taken');
      } else {
        _showMessage('Failed to save username: $msg');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Choose a username',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _controller,
            label: 'Username',
            hint: 'your_username',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveUsername,
              style: AppButtonStyles.primaryButton(context),
              child: _isLoading 
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                  )
                : const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
