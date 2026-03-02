import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  // This creates mutable state for username onboarding logic.
  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  final _usernameAllowedRegex = RegExp(r'^[a-z0-9_]+$');

  // This normalizes username into a case-insensitive key.
  String _normalizeUsername(String value) => value.trim().toLowerCase();

  // This pre-fills username input if a name already exists.
  @override
  void initState() {
    super.initState();
    final currentName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    _controller.text = currentName;
  }

  // This disposes controller resources when page is removed.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // This shows a user-facing status/error message.
  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // This validates and saves a unique username to Auth + Firestore.
  Future<void> _saveUsername() async {
    final username = _controller.text.trim();
    if (username.isEmpty) {
      _showMessage('Username is required');
      return;
    }
    if (username.contains(' ')) {
      _showMessage('No spaces are allowed in username');
      return;
    }
    if (!_usernameAllowedRegex.hasMatch(username.toLowerCase())) {
      _showMessage(
        'Username can only use letters, numbers, and underscores',
      );
      return;
    }
    if (username.length < 3 || username.length > 20) {
      _showMessage('Username must be between 3 and 20 characters');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('No authenticated user found');
      return;
    }

    // Firestore docs used to enforce one-username-per-user globally.
    final normalized = _normalizeUsername(username);
    final db = FirebaseFirestore.instance;
    final usersRef = db.collection('users').doc(user.uid);
    final usernameRef = db.collection('usernames').doc(normalized);

    setState(() => _isLoading = true);
    try {
      // Transaction prevents race conditions when reserving usernames.
      await db.runTransaction((txn) async {
        final usernameSnap = await txn.get(usernameRef);
        if (usernameSnap.exists) {
          final existingUid = usernameSnap.data()?['uid'] as String?;
          if (existingUid != null && existingUid != user.uid) {
            throw StateError('USERNAME_TAKEN');
          }
        }

        // Remove old reservation if user changes username.
        final userSnap = await txn.get(usersRef);
        final previousNormalized =
            userSnap.data()?['usernameNormalized'] as String?;
        if (previousNormalized != null && previousNormalized != normalized) {
          final previousRef = db.collection('usernames').doc(previousNormalized);
          final previousSnap = await txn.get(previousRef);
          final previousUid = previousSnap.data()?['uid'] as String?;
          if (previousSnap.exists && previousUid == user.uid) {
            txn.delete(previousRef);
          }
        }

        // Reserve username and update user profile atomically.
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
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      // Keep Firebase Auth display name in sync with Firestore username.
      await user.updateDisplayName(username);
      await user.reload();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on StateError catch (e) {
      if (e.message == 'USERNAME_TAKEN') {
        _showMessage('That username is already taken');
      } else {
        _showMessage('Failed to save username');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Failed to save username');
    } on FirebaseException catch (e) {
      _showMessage(e.message ?? 'Failed to save username');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // This builds the mandatory username onboarding screen.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter username'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Choose a username',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveUsername,
                    child: const Text('Continue'),
                  ),
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
