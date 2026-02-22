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

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
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
