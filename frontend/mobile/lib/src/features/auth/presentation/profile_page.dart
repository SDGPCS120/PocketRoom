import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // This builds the profile page and logout action.
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '(no email)';
    final uid = user?.uid;

    final usernameFromAuth = (user?.displayName ?? '').trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: uid == null
                    ? null
                    : FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final usernameFromFirestore =
                      (data?['username'] as String? ?? '').trim();
                  final roleFromFirestore = (data?['role'] as String? ?? '').trim();
                  final effectiveUsername = usernameFromFirestore.isNotEmpty
                      ? usernameFromFirestore
                      : usernameFromAuth;
                  final effectiveRole = roleFromFirestore.isNotEmpty
                      ? roleFromFirestore
                      : ((user?.isAnonymous ?? false) ? 'anonymous' : 'customer');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username: ${effectiveUsername.isEmpty ? "(not set)" : effectiveUsername}',
                      ),
                      const SizedBox(height: 8),
                      Text('Role: $effectiveRole'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text('Email: $email'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    // Sign out from Google first so account chooser appears next time.
                    await GoogleSignIn().signOut();
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Log out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
