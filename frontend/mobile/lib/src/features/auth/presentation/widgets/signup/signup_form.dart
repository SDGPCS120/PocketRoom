import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/email_validation.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/auth_models.dart';
import '../auth_text_field.dart';
import '../auth_confirm_password_dialog.dart';
import '../../login_page.dart';
import '../../username_page.dart';
import '../../../../home/presentation/main_screen.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleOutcome(AuthOutcome outcome) {
    if (!mounted) return;
    if (outcome == AuthOutcome.needsUsername) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UsernamePage()),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final emailError = await EmailValidation.validateForSubmission(
        _emailController.text,
      );
      if (emailError != null) {
        _showMessage(emailError);
        return;
      }

      final outcome = await ref
          .read(authControllerProvider)
          .signUpWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text,
          );
      _handleOutcome(outcome);
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final outcome = await ref.read(authControllerProvider).signInWithGoogle();
      _handleOutcome(outcome);
    } on RequiresPasswordException catch (req) {
      if (!mounted) return;
      final password = await AuthConfirmPasswordDialog.show(context, req.email);
      if (!mounted) return;

      if (password != null && password.isNotEmpty) {
        try {
          final outcome = await ref
              .read(authControllerProvider)
              .linkExistingAccount(req.email, password, req.credential);
          _handleOutcome(outcome);
        } catch (e) {
          _showMessage('Failed to link account: ${e.toString()}');
        }
      } else {
        _showMessage('Password required to link Google to existing account');
      }
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 28,
        vertical: isDesktop ? 40 : 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create Account',
              style: AppTextStyles.h1(
                context,
              ).copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              'Create an account to buy your favorite furniture',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 36),
            AuthTextField(
              controller: _nameController,
              label: 'Username',
              hint: 'your_username',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: EmailValidation.validateSyntax,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: '********',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmController,
              label: 'Confirm password',
              hint: '********',
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) => (v != _passwordController.text)
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: AppButtonStyles.primaryButton(context),
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Create account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: colorScheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: colorScheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : _signInWithGoogle,
                style: AppButtonStyles.outlinedButton(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: Text(
                    'Log in',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
