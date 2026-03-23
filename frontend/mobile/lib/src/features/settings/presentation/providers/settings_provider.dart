import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api_config.dart';
import '../../../../core/firebase_providers.dart';
import '../../data/models/settings_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this.ref) : super(const SettingsState());

  final Ref ref;

  FirebaseFirestore get _firestore => ref.read(firestoreProvider);

  void togglePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
  }

  void toggleOrderUpdates(bool value) {
    state = state.copyWith(orderUpdates: value);
  }

  void setLanguage(String value) {
    state = state.copyWith(selectedLanguage: value);
  }

  Future<void> launchPocketRoom() async {
    final uri = Uri.parse('https://www.pocketroom.lk');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> logout() async {
    if (state.isLoggingOut) return false;

    state = state.copyWith(isLoggingOut: true);
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInAnonymously();
      return true;
    } catch (_) {
      state = state.copyWith(isLoggingOut: false);
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (state.isDeletingAccount) return false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      throw Exception('No signed-in account found to delete');
    }

    state = state.copyWith(isDeletingAccount: true);
    try {
      final token = await user.getIdToken(true);
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 404) {
        await _anonymizeAndDeleteLocally(user);
      } else if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to delete account (${response.statusCode})');
      }

      await _resetToAnonymousSession();
      return true;
    } catch (_) {
      state = state.copyWith(isDeletingAccount: false);
      rethrow;
    }
  }

  Future<void> _anonymizeAndDeleteLocally(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userSnap = await userRef.get();
    final oldUsernameNormalized =
        (userSnap.data()?['usernameNormalized'] as String? ?? '').trim();
    final placeholderUsername = _buildDeletedUsername(user.uid);
    final placeholderUsernameRef = _firestore
        .collection('usernames')
        .doc(placeholderUsername);

    final batch = _firestore.batch();
    batch.set(placeholderUsernameRef, {
      'uid': user.uid,
      'username': placeholderUsername,
      'usernameNormalized': placeholderUsername,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(userRef, {
      'uid': user.uid,
      'email': null,
      'fullName': 'Deleted User',
      'phone': '',
      'address': '',
      'username': placeholderUsername,
      'usernameNormalized': placeholderUsername,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (oldUsernameNormalized.isNotEmpty &&
        oldUsernameNormalized != placeholderUsername) {
      batch.delete(
        _firestore.collection('usernames').doc(oldUsernameNormalized),
      );
    }

    try {
      await batch.commit();
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw Exception(
          'Account deletion needs the backend delete endpoint because your Firestore rules block client-side removal.',
        );
      }
      rethrow;
    }

    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        throw Exception('Please log in again before deleting your account');
      }
      rethrow;
    }
  }

  String _buildDeletedUsername(String uid) {
    final normalized = uid.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = normalized.isEmpty ? 'user' : normalized;
    final candidate = 'del$suffix';
    return candidate.length <= 20 ? candidate : candidate.substring(0, 20);
  }

  Future<void> _resetToAnonymousSession() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInAnonymously();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier(ref);
  },
);
