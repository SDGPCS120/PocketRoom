import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'login_page.dart';
import '../../home/presentation/home_page.dart';
import 'username_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
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
  String _sanitizeUsername(String value) => value.trim().replaceAll(RegExp(r'\s+'), '_');

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _sanitizeUsername(_nameController.text);
    _nameController.text = username;
    if (!_usernameAllowedRegex.hasMatch(username.toLowerCase())) {
      _showMessage('Username can only use letters, numbers, and underscores');
      return;
    }
    if (username.length < 3 || username.length > 20) {
      _showMessage('Username must be between 3 and 20 characters');
      return;
    }

    setState(() => _loading = true);

    final auth = ref.read(firebaseAuthProvider);
    final db = ref.read(firestoreProvider);
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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                
                final content = SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 28, 
                    vertical: isDesktop ? 40 : (56 + 16) 
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
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: const TextStyle(
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
                            onPressed: _loading ? null : () {}, 
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.cardBorder),
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.login, size: 20),
                                const SizedBox(width: 12),
                                const Text(
                                  'Continue with Google', 
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
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
                              child: Text(
                                'Log in',
                                style: GoogleFonts.fredoka(
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

                if (!isDesktop) return content;

                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: content,
                  ),
                );
              },
            ),
          ],
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
