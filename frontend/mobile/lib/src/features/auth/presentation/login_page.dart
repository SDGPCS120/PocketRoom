import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/theme/app_theme.dart';
import 'create_account_page.dart';
import 'signup_page.dart';
import 'username_page.dart';
import '../../home/presentation/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _logAuth(String message) {
    final line = '[AUTH_LOG] $message';
    debugPrint(line);
    developer.log(line, name: 'AuthFlow');
    stdout.writeln(line);
  }

  Future<void> _printAuthInfo(User user, String providerLabel) async {
    _logAuth('=== $providerLabel LOGIN SUCCESS ===');
    final token = await user.getIdToken(true);
    if (token == null) {
      _logAuth('$providerLabel token is null for uid=${user.uid}');
      return;
    }

    _logAuth('$providerLabel UID: ${user.uid}');
    _logAuth('$providerLabel isAnonymous: ${user.isAnonymous}');
    _logAuth('$providerLabel Email: ${user.email ?? "(no email)"}');
    _logAuth('$providerLabel TOKEN LENGTH: ${token.length}');

    const chunkSize = 600;
    for (int i = 0; i < token.length; i += chunkSize) {
      final end = (i + chunkSize < token.length) ? i + chunkSize : token.length;
      _logAuth(
        '${providerLabel.toUpperCase()}_TOKEN_PART ${i ~/ chunkSize}: ${token.substring(i, end)}',
      );
    }
    _logAuth('=== END $providerLabel TOKEN ===');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _closeOnSuccess(UserCredential credential) async {
    final user = credential.user;
    if (user == null) return;
    if (!mounted) return;
    if ((user.displayName ?? '').trim().isEmpty) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UsernamePage()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = FirebaseAuth.instance;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        final linked = await currentUser.linkWithCredential(credential);
        if (linked.user != null) {
          await _printAuthInfo(linked.user!, 'EmailPassword');
        }
        await _closeOnSuccess(linked);
      } else {
        final signedIn = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (signedIn.user != null) {
          await _printAuthInfo(signedIn.user!, 'EmailPassword');
        }
        await _closeOnSuccess(signedIn);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' ||
          e.code == 'credential-already-in-use') {
        try {
          final signedIn = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (signedIn.user != null) {
            await _printAuthInfo(signedIn.user!, 'EmailPassword');
          }
          await _closeOnSuccess(signedIn);
        } on FirebaseAuthException catch (fallback) {
          _showMessage(fallback.message ?? 'Email/password login failed');
        }
      } else {
        _showMessage(e.message ?? 'Email/password login failed');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = FirebaseAuth.instance;
    final googleSignIn = GoogleSignIn();

    Future<GoogleSignInAccount?> pickGoogleUser() async {
      await googleSignIn.signOut();
      return googleSignIn.signIn();
    }

    try {
      final googleUser = await pickGoogleUser();
      if (googleUser == null) {
        _showMessage('Google sign-in cancelled');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        final linked = await currentUser.linkWithCredential(credential);
        if (linked.user != null) {
          await _printAuthInfo(linked.user!, 'Google');
        }
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UsernamePage()),
        );
      } else {
        final signedIn = await auth.signInWithCredential(credential);
        if (signedIn.user != null) {
          await _printAuthInfo(signedIn.user!, 'Google');
        }
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UsernamePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'provider-already-linked') {
        try {
          final googleUser = await pickGoogleUser();
          if (googleUser == null) return;
          final googleAuth = await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final signedIn = await auth.signInWithCredential(credential);
          if (signedIn.user != null) {
            await _printAuthInfo(signedIn.user!, 'Google');
          }
          if (!mounted) return;
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const UsernamePage()),
          );
        } on FirebaseAuthException catch (fallback) {
          _showMessage(fallback.message ?? 'Google login failed');
        }
      } else {
        _showMessage(e.message ?? 'Google login failed');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  'Welcome back',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in with email/password or continue with Google.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // Email field
                _AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),

                // Password field
                _AuthTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your password' : null,
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: forgot password flow
                    },
                    child: Text(
                      'Forgot password?',
                      style: GoogleFonts.fredoka(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Log in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Log in',
                      style: GoogleFonts.fredoka(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Google sign-in button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Login with Google',
                      style: GoogleFonts.fredoka(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Navigate to Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      ),
                      child: Text(
                        'Create one',
                        style: GoogleFonts.fredoka(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_isLoading) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable styled text field used in Login and Signup screens.
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
