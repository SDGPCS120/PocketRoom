import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';

class FavoritesNotifier extends Notifier<List<Furniture>> {
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favoritesSubscription;
  String? _activeUid;

  @override
  List<Furniture> build() {
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen(
      _handleAuthChanged,
    );
    ref.onDispose(() async {
      await _authSubscription?.cancel();
      await _favoritesSubscription?.cancel();
    });
    return [];
  }

  void toggleFavorite(Furniture furniture) {
    final isFav = state.any((item) => item.id == furniture.id);
    if (isFav) {
      state = state.where((item) => item.id != furniture.id).toList();
    } else {
      state = [...state, furniture];
    }
    unawaited(_persistFavoritesForSignedInUser());
  }

  bool isFavorite(String furnitureId) {
    return state.any((item) => item.id == furnitureId);
  }

  Future<void> _handleAuthChanged(User? user) async {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = null;

    if (user == null || user.isAnonymous) {
      _activeUid = null;
      state = [];
      return;
    }

    _activeUid = user.uid;
    
    // Sync with Firestore
    _favoritesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .listen((snapshot) {
          state = snapshot.docs
              .map((doc) => Furniture.fromJson(doc.data()))
              .toList();
        }, onError: (_) {
          // Keep current in-memory state if Firestore denies access
        });
  }

  Future<void> _persistFavoritesForSignedInUser() async {
    final uid = _activeUid;
    if (uid == null) return;

    final favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');
        
    final batch = FirebaseFirestore.instance.batch();

    // In a real app we might want to be more efficient than wiping and re-writing
    // but for simplicity and consistency with CartNotifier:
    final existingDocs = await favoritesCollection.get();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    for (final furniture in state) {
      final docRef = favoritesCollection.doc(furniture.id);
      batch.set(docRef, furniture.toJson());
    }

    try {
      await batch.commit();
    } catch (_) {
      // Silently handle errors
    }
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Furniture>>(FavoritesNotifier.new);
