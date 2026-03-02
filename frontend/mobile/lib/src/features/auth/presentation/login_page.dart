import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/theme/app_theme.dart';
import 'create_account_page.dart';
import 'username_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // This creates the mutable state for login form and auth actions.
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // This logs auth flow messages to terminal and debug tools.
  void _logAuth(String message) {
    final line = '[AUTH_LOG] $message';
    debugPrint(line);
    developer.log(line, name: 'AuthFlow');
    stdout.writeln(line);
  }

  // This prints user/token details after a successful login.
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

  // This disposes text controllers to avoid memory leaks.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // This shows a user-friendly message on the current page.
  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // This routes users to username setup if profile name is missing.
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

  // This handles email/password login or anonymous-account linking.
  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = FirebaseAuth.instance;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final currentUser = auth.currentUser;
      // Link credential to anonymous user so UID/data are preserved.
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
        // Regular email/password sign-in for existing users.
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
          // Fallback to sign-in if credential already exists.
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

  // This handles Google sign-in and upgrades anonymous users when needed.
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    final auth = FirebaseAuth.instance;
    final googleSignIn = GoogleSignIn();

    // This forces account picker to appear every login attempt.
    Future<GoogleSignInAccount?> pickGoogleUser() async {
      // Clear last selected Google account so chooser appears every time.
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
      // Link Google credential to anonymous user to keep same account.
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
        // Regular Google login flow for non-anonymous users.
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
          // Fallback to direct credential sign-in when linking is not allowed.
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

  // This builds the login form UI and actions.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in with email/password or continue with Google.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('Login with Google'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateAccountPage(),
                            ),
                          );
                        },
                  child: const Text('Create an account'),
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
