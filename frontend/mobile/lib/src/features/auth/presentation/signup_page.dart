import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'login_page.dart';
import '../../home/presentation/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  final _usernameAllowedRegex = RegExp(r'^[a-z0-9_]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _normalizeUsername(String value) => value.trim().toLowerCase();

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _nameController.text.trim();
    if (username.contains(' ')) {
      _showMessage('No spaces are allowed in username');
      return;
    }
    if (!_usernameAllowedRegex.hasMatch(username.toLowerCase())) {
      _showMessage('Username can only use letters, numbers, and underscores');
      return;
    }
    if (username.length < 3 || username.length > 20) {
      _showMessage('Username must be between 3 and 20 characters');
      return;
    }

    setState(() => _loading = true);

    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final normalized = _normalizeUsername(username);

    try {
      UserCredential credential;
      final currentUser = auth.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        final emailCredential = EmailAuthProvider.credential(email: email, password: password);
        credential = await currentUser.linkWithCredential(emailCredential);
      } else {
        credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      }

      final user = credential.user;
      if (user == null) {
        _showMessage('Failed to create account');
        return;
      }

      final usersRef = db.collection('users').doc(user.uid);
      final usernameRef = db.collection('usernames').doc(normalized);

      await db.runTransaction((txn) async {
        final usernameSnap = await txn.get(usernameRef);
        if (usernameSnap.exists) {
          final existingUid = usernameSnap.data()?['uid'] as String?;
          if (existingUid != null && existingUid != user.uid) {
            throw StateError('USERNAME_TAKEN');
          }
        }

        txn.set(usernameRef, {
          'uid': user.uid,
          'username': username,
          'usernameNormalized': normalized,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        txn.set(usersRef, {
          'uid': user.uid,
          'email': user.email,
          'username': username,
          'usernameNormalized': normalized,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      await user.updateDisplayName(username);
      await user.reload();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (_) => false,
      );
    } on StateError catch (e) {
      if (e.message == 'USERNAME_TAKEN') {
        _showMessage('That username is already taken');
      } else {
        _showMessage('Account creation failed');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Account creation failed');
    } on FirebaseException catch (e) {
      _showMessage(e.message ?? 'Account creation failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Create account',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join PocketRoom and start exploring',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),
                _AuthTextField(
                  controller: _nameController,
                  label: 'Username',
                  hint: 'your_username',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                ),
                const SizedBox(height: 16),
                _AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                _AuthTextField(
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
                _AuthTextField(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Create account', style: GoogleFonts.fredoka(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 24),
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
                      child: Text(
                        'Log in',
                        style: GoogleFonts.fredoka(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.secondary,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
