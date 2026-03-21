import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// A dialog that prompts the user to enter their password to link an existing 
/// email/password account with a Google login.
class AuthConfirmPasswordDialog extends StatefulWidget {
  final String email;

  const AuthConfirmPasswordDialog({super.key, required this.email});

  /// Shows the dialog and returns the entered password if the user clicks 'Continue'.
  static Future<String?> show(BuildContext context, String email) {
    return showDialog<String>(
      context: context,
      builder: (context) => AuthConfirmPasswordDialog(email: email),
    );
  }

  @override
  State<AuthConfirmPasswordDialog> createState() => _AuthConfirmPasswordDialogState();
}

class _AuthConfirmPasswordDialogState extends State<AuthConfirmPasswordDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Confirm account', 
        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter password for ${widget.email} to link Google login to your existing account.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (val) => Navigator.of(context).pop(val.trim()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
