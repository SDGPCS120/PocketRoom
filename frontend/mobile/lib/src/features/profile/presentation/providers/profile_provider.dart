import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/api_config.dart';
import '../../../../core/utils/email_validation.dart';
import '../../data/models/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  late final StreamSubscription<User?> _authSubscription;

  ProfileNotifier() : super(const ProfileState()) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      loadUserData();
    });
    loadUserData();
  }

  Future<void> loadUserData() async {
    state = state.copyWith(isLoading: true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      state = const ProfileState(isLoading: false);
      return;
    }

    final isAnonymous = user.isAnonymous;
    String name = '';
    String email = (user.email ?? '').trim();
    String role = isAnonymous ? 'anonymous' : 'customer';
    String phone = '';
    String address = '';

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();
      if (data != null) {
        final dbFullName = (data['fullName'] as String? ?? '').trim();
        final dbUsername = (data['username'] as String? ?? '').trim();
        if (dbFullName.isNotEmpty) {
          name = dbFullName;
        } else if (dbUsername.isNotEmpty) {
          name = dbUsername;
        }

        final dbEmail = (data['email'] as String? ?? '').trim();
        if (dbEmail.isNotEmpty) {
          email = dbEmail;
        }

        phone = (data['phone'] as String? ?? '').trim();
        address = (data['address'] as String? ?? '').trim();

        final dbRole = (data['role'] as String? ?? '').trim();
        if (dbRole.isNotEmpty) {
          role = dbRole;
        }
      }
    } catch (_) {
      // Keep Firebase Auth fallback values when Firestore is unavailable.
    }

    if (name.isEmpty) {
      name = (user.displayName ?? '').trim();
    }

    if (name.isEmpty) {
      if (email.isNotEmpty && email.contains('@')) {
        name = email.split('@').first;
      } else {
        name = 'Profile';
      }
    }

    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      address: address,
      role: role,
      isAnonymousUser: isAnonymous,
      isLoading: false,
    );
  }

  Future<void> saveUserData({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No signed-in user found');
    }

    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();
    final trimmedAddress = address.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Enter your name');
    }

    final emailError = await EmailValidation.validateForSubmission(
      trimmedEmail,
    );
    if (emailError != null) {
      throw Exception(emailError);
    }

    state = state.copyWith(isLoading: true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': trimmedEmail,
      'fullName': trimmedName,
      'phone': trimmedPhone,
      'address': trimmedAddress,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (trimmedName != (user.displayName ?? '').trim()) {
      await user.updateDisplayName(trimmedName);
    }

    await user.reload();

    state = state.copyWith(
      name: trimmedName,
      email: trimmedEmail,
      phone: trimmedPhone,
      address: trimmedAddress,
      isLoading: false,
    );
  }

  Future<String?> fetchCartDebugJson() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    try {
      final token = await user.getIdToken(true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart-debug/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Request failed with status ${response.statusCode}');
      }

      final parsed = jsonDecode(response.body);
      return const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
