import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../../../core/api_config.dart';
import '../../data/models/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState()) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    state = state.copyWith(isLoading: true);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final isAnonymous = user.isAnonymous;
    String name = (user.displayName ?? '').trim();
    String email = user.email ?? '';
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
        final dbUsername = (data['username'] as String? ?? '').trim();
        if (dbUsername.isNotEmpty) name = dbUsername;
        
        phone = (data['phone'] as String? ?? '').trim();
        address = (data['address'] as String? ?? '').trim();
        
        final dbRole = (data['role'] as String? ?? '').trim();
        if (dbRole.isNotEmpty) role = dbRole;
      }
    } catch (_) {
      // Keep Firebase Auth fallback values when Firestore is unavailable
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

  void updateUserData({String? name, String? email, String? phone, String? address}) {
    state = state.copyWith(
      name: name ?? state.name,
      email: email ?? state.email,
      phone: phone ?? state.phone,
      address: address ?? state.address,
    );
  }

  Future<bool> logout() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInAnonymously();
      return true;
    } catch (_) {
      return false;
    }
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
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
