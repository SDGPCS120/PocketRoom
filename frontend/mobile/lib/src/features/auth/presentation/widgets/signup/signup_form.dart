import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/auth_models.dart';
import '../auth_text_field.dart';
import '../auth_confirm_password_dialog.dart';
import '../../login_page.dart';
import '../../username_page.dart';
import '../../../../home/presentation/home_page.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleOutcome(AuthOutcome outcome) {
    if (!mounted) return;
    if (outcome == AuthOutcome.needsUsername) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UsernamePage()));
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final outcome = await ref.read(authControllerProvider).signUpWithEmailPassword(
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
    } on RequiresPasswordException catch(req) {
      final password = await AuthConfirmPasswordDialog.show(context, req.email);
      if (password != null && password.isNotEmpty) {
        try {
          final outcome = await ref.read(authControllerProvider).linkExistingAccount(req.email, password, req.credential);
          _handleOutcome(outcome);
        } catch(e) {
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
              'Join PocketRoom',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create an account to buy your favorite furniture',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 36),
            AuthTextField(
              controller: _nameController,
              label: 'Username',
              hint: 'your_username',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
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
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
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
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) => (v != _passwordController.text) ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: AppButtonStyles.primaryButton,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Create account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.cardBorder)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.cardBorder)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : _signInWithGoogle,
                style: AppButtonStyles.outlinedButton,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 20, color: AppColors.textPrimary),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)
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
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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
