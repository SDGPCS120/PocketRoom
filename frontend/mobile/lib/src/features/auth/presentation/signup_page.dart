import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase_providers.dart';
import '../../../core/theme/app_theme.dart';
import 'login_page.dart';
import '../../home/presentation/main_screen.dart';
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
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      await user.updateDisplayName(username);
      await user.reload();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
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

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
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
        await _closeOnSuccess(existing);
        return;
      }

      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        try {
          final linked = await currentUser.linkWithCredential(credential);
          await _closeOnSuccess(linked);
        } on FirebaseAuthException {
          final signedIn = await auth.signInWithCredential(credential);
          await _closeOnSuccess(signedIn);
        }
      } else {
        final signedIn = await auth.signInWithCredential(credential);
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
          await _closeOnSuccess(existing);
        } on FirebaseAuthException catch (fallback) {
          _showMessage(fallback.message ?? 'Google login failed');
        }
      } else {
        _showMessage(e.message ?? 'Google login failed');
      }
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;

            final content = SingleChildScrollView(
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
                                const Icon(Icons.login, size: 20), // Placeholder for Google icon
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

            if (!isDesktop) {
              return content;
            }

            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
