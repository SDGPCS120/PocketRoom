import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/firebase_providers.dart';

import '../../data/models/auth_models.dart';

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  FirebaseAuth get auth => ref.read(firebaseAuthProvider);
  FirebaseFirestore get db => ref.read(firestoreProvider);
  final _usernameAllowedRegex = RegExp(r'^[a-z0-9_]+$');

  String normalizeUsername(String value) => value.trim().toLowerCase();
  String sanitizeUsername(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '_');

  Future<AuthOutcome> processUserCredential(UserCredential credential) async {
    final user = credential.user;
    if (user == null) throw Exception("User is null");

    final snap = await db.collection('users').doc(user.uid).get();
    final data = snap.data();
    final username = (data?['username'] as String?)?.trim();

    final isValidFirestoreUsername =
        username != null &&
        _usernameAllowedRegex.hasMatch(username.toLowerCase());

    if (!isValidFirestoreUsername) {
      return AuthOutcome.needsUsername;
    } else {
      if ((user.displayName ?? '').trim() != username) {
        await user.updateDisplayName(username);
        await user.reload();
      }
      return AuthOutcome.success;
    }
  }

  Future<AuthOutcome> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return processUserCredential(credential);
  }

  Future<AuthOutcome> signUpWithEmailPassword(
    String email,
    String password,
    String rawUsername,
  ) async {
    final username = sanitizeUsername(rawUsername);
    if (!_usernameAllowedRegex.hasMatch(username.toLowerCase())) {
      throw Exception(
        'Username can only use letters, numbers, and underscores',
      );
    }
    if (username.length < 3 || username.length > 20) {
      throw Exception('Username must be between 3 and 20 characters');
    }

    final normalized = normalizeUsername(username);
    final usernameRef = db.collection('usernames').doc(normalized);

    // Quick pre-check before hitting Auth
    final checkSnap = await usernameRef.get();
    if (checkSnap.exists) {
      throw StateError('USERNAME_TAKEN');
    }

    final currentUser = auth.currentUser;
    UserCredential credential;

    if (currentUser != null && currentUser.isAnonymous) {
      final emailCredential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      credential = await currentUser.linkWithCredential(emailCredential);
    } else {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    final user = credential.user;
    if (user == null) throw Exception('Failed to create account');

    final usersRef = db.collection('users').doc(user.uid);

    await db.runTransaction((txn) async {
      final snap = await txn.get(usernameRef);
      if (snap.exists) {
        final existingUid = snap.data()?['uid'] as String?;
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

    return AuthOutcome.success;
  }

  Future<AuthOutcome> reserveUsername(String rawUsername) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    final username = sanitizeUsername(rawUsername);
    if (!_usernameAllowedRegex.hasMatch(username.toLowerCase())) {
      throw Exception(
        'Username can only use letters, numbers, and underscores',
      );
    }
    if (username.length < 3 || username.length > 20) {
      throw Exception('Username must be between 3 and 20 characters');
    }

    final normalized = normalizeUsername(username);
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

    await user.updateDisplayName(username);
    await user.reload();
    return AuthOutcome.success;
  }

  Future<AuthOutcome> linkExistingAccount(
    String email,
    String password,
    AuthCredential googleCredential,
  ) async {
    final signedIn = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = signedIn.user;
    if (user != null) {
      try {
        await user.linkWithCredential(googleCredential);
      } on FirebaseAuthException catch (e) {
        if (e.code != 'provider-already-linked' &&
            e.code != 'credential-already-in-use') {
          rethrow;
        }
      }
    }
    return processUserCredential(signedIn);
  }

  Future<AuthOutcome> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final pendingEmail = googleUser.email.trim();

    // ignore: deprecated_member_use
    final methods = await auth.fetchSignInMethodsForEmail(pendingEmail);
    final hasPassword = methods.contains('password');
    final hasGoogle = methods.contains('google.com');

    if (hasPassword && !hasGoogle) {
      throw RequiresPasswordException(pendingEmail, credential);
    }

    final currentUser = auth.currentUser;
    UserCredential signedIn;

    if (currentUser != null && currentUser.isAnonymous) {
      try {
        signedIn = await currentUser.linkWithCredential(credential);
      } on FirebaseAuthException {
        signedIn = await auth.signInWithCredential(credential);
      }
    } else {
      signedIn = await auth.signInWithCredential(credential);
    }

    return processUserCredential(signedIn);
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});
