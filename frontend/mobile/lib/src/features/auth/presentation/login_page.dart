import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/theme/app_theme.dart';
import 'signup_page.dart';
import 'username_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _usernameAllowedRegex = RegExp(r'^[a-z0-9_]+$');

  void _logAuth(String message) {
    final line = '[AUTH_LOG] $message';
    debugPrint(line);
    developer.log(line, name: 'AuthFlow');
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
    const chunkSize = 800;
    for (int i = 0; i < token.length; i += chunkSize) {
      final end = (i + chunkSize < token.length) ? i + chunkSize : token.length;
      _logAuth(
        '${providerLabel.toUpperCase()}_TOKEN_PART ${i ~/ chunkSize}: ${token.substring(i, end)}',
      );
    }
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

  Future<String?> _getFirestoreUsername(String uid) async {
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data();
    final username = (data?['username'] as String?)?.trim();
    if (username == null || username.isEmpty) return null;
    return username;
  }

  Future<void> _closeOnSuccess(UserCredential credential) async {
    final user = credential.user;
    if (user == null || !mounted) return;

    final firestoreUsername = await _getFirestoreUsername(user.uid);
    final isValidFirestoreUsername =
        firestoreUsername != null &&
        _usernameAllowedRegex.hasMatch(firestoreUsername.toLowerCase());

    if (!isValidFirestoreUsername) {
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const UsernamePage()));
    } else {
      if ((user.displayName ?? '').trim() != firestoreUsername) {
        await user.updateDisplayName(firestoreUsername);
        await user.reload();
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<String?> _promptPasswordForLink(String email) async {
    final controller = TextEditingController();
    var obscure = true;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirm account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter password for $email to link Google login.'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<UserCredential?> _signInExistingAndLinkGoogle({
    required String email,
    required AuthCredential googleCredential,
  }) async {
    final auth = FirebaseAuth.instance;
    var password = _passwordController.text.trim();
    if (password.isEmpty) {
      password = (await _promptPasswordForLink(email)) ?? '';
    }
    if (password.isEmpty) return null;

    final signedIn = await auth.signInWithEmailAndPassword(email: email, password: password);
    final user = signedIn.user;
    if (user != null) {
      try {
        await user.linkWithCredential(googleCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'provider-already-linked' && e.code != 'credential-already-in-use') {
          rethrow;
        }
      }
    }
    return signedIn;
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
        try {
          final credential = EmailAuthProvider.credential(email: email, password: password);
          final linked = await currentUser.linkWithCredential(credential);
          if (linked.user != null) await _printAuthInfo(linked.user!, 'EmailPassword');
          await _closeOnSuccess(linked);
        } on FirebaseAuthException {
          final signedIn = await auth.signInWithEmailAndPassword(email: email, password: password);
          if (signedIn.user != null) await _printAuthInfo(signedIn.user!, 'EmailPassword');
          await _closeOnSuccess(signedIn);
        }
      } else {
        final signedIn = await auth.signInWithEmailAndPassword(email: email, password: password);
        if (signedIn.user != null) await _printAuthInfo(signedIn.user!, 'EmailPassword');
        await _closeOnSuccess(signedIn);
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Email/password login failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = FirebaseAuth.instance;
    final googleSignIn = GoogleSignIn();
    String? pendingEmail;
    AuthCredential? pendingGoogleCredential;

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
      pendingEmail = googleUser.email.trim();
      pendingGoogleCredential = credential;

      // ignore: deprecated_member_use
      final methods = await auth.fetchSignInMethodsForEmail(pendingEmail);
      final hasPassword = methods.contains('password');
      final hasGoogle = methods.contains('google.com');
      if (hasPassword && !hasGoogle) {
        final existing = await _signInExistingAndLinkGoogle(
          email: pendingEmail,
          googleCredential: credential,
        );
        if (existing == null) {
          _showMessage('Password required to link Google to existing account');
          return;
        }
        if (existing.user != null) await _printAuthInfo(existing.user!, 'Google');
        await _closeOnSuccess(existing);
        return;
      }

      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        try {
          final linked = await currentUser.linkWithCredential(credential);
          if (linked.user != null) await _printAuthInfo(linked.user!, 'Google');
          await _closeOnSuccess(linked);
        } on FirebaseAuthException {
          final signedIn = await auth.signInWithCredential(credential);
          if (signedIn.user != null) await _printAuthInfo(signedIn.user!, 'Google');
          await _closeOnSuccess(signedIn);
        }
      } else {
        final signedIn = await auth.signInWithCredential(credential);
        if (signedIn.user != null) await _printAuthInfo(signedIn.user!, 'Google');
        await _closeOnSuccess(signedIn);
      }
    } on FirebaseAuthException catch (e) {
      if ((e.code == 'account-exists-with-different-credential' ||
              e.code == 'email-already-in-use') &&
          pendingEmail != null &&
          pendingGoogleCredential != null) {
        try {
          final existing = await _signInExistingAndLinkGoogle(
            email: pendingEmail,
            googleCredential: pendingGoogleCredential,
          );
          if (existing == null) {
            _showMessage('Password required to link Google to existing account');
            return;
          }
          if (existing.user != null) await _printAuthInfo(existing.user!, 'Google');
          await _closeOnSuccess(existing);
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
                  'Log in to your PocketRoom account',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),
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
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Log in', style: GoogleFonts.fredoka(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Login with Google', style: GoogleFonts.fredoka(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => Navigator.push(
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
