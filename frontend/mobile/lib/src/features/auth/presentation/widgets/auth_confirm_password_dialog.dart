import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Confirm account', 
        style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter password for ${widget.email} to link Google login to your existing account.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            autofocus: true,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurfaceVariant,
                ),
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
          child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
