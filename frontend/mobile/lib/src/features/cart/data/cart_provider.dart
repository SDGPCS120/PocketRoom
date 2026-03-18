import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import './models/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;
  String? _activeUid;

  @override
  List<CartItem> build() {
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen(
      _handleAuthChanged,
    );
    ref.onDispose(() async {
      await _authSubscription?.cancel();
      await _cartSubscription?.cancel();
    });
    return [];
  }

  void addItem(Furniture furniture) {
    final existingIndex = state.indexWhere((item) => item.furniture.id == furniture.id);
    if (existingIndex != -1) {
      final existingItem = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: existingItem.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(furniture: furniture)];
    }
    unawaited(_persistCartForSignedInUser());
  }

  void removeItem(String furnitureId) {
    state = state.where((item) => item.furniture.id != furnitureId).toList();
    unawaited(_persistCartForSignedInUser());
  }

  void incrementQuantity(String furnitureId) {
    final index = state.indexWhere((item) => item.furniture.id == furnitureId);
    if (index != -1) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(index + 1),
      ];
      unawaited(_persistCartForSignedInUser());
    }
  }

  void decrementQuantity(String furnitureId) {
    final index = state.indexWhere((item) => item.furniture.id == furnitureId);
    if (index != -1) {
      final item = state[index];
      if (item.quantity > 1) {
        state = [
          ...state.sublist(0, index),
          item.copyWith(quantity: item.quantity - 1),
          ...state.sublist(index + 1),
        ];
        unawaited(_persistCartForSignedInUser());
      } else {
        removeItem(furnitureId);
      }
    }
  }

  double get totalPrice {
    return state.fold(0, (total, item) => total + (item.furniture.price * item.quantity));
  }

  Future<void> _handleAuthChanged(User? user) async {
    _cartSubscription?.cancel();
    _cartSubscription = null;

    // Keep cart account-scoped: anonymous and logged-out sessions start empty.
    if (user == null || user.isAnonymous) {
      _activeUid = null;
      state = [];
      return;
    }

    _activeUid = user.uid;
    final localItemsBeforeSync = List<CartItem>.from(state);
    if (localItemsBeforeSync.isNotEmpty) {
      await _mergeLocalItemsIntoRemoteCart(user.uid, localItemsBeforeSync);
    }

    _cartSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
          state = snapshot.docs
              .map((doc) => _cartItemFromDoc(doc.data()))
              .whereType<CartItem>()
              .toList();
        }, onError: (_) {
          // Keep current in-memory state if Firestore denies this read.
        });
  }

  Future<void> _mergeLocalItemsIntoRemoteCart(
    String uid,
    List<CartItem> localItems,
  ) async {
    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
    final existingSnapshot = await cartCollection.get();
    final existingById = <String, CartItem>{};
    for (final doc in existingSnapshot.docs) {
      final item = _cartItemFromDoc(doc.data());
      if (item != null) {
        existingById[item.furniture.id] = item;
      }
    }

    final batch = FirebaseFirestore.instance.batch();
    for (final localItem in localItems) {
      final existing = existingById[localItem.furniture.id];
      final mergedQuantity = (existing?.quantity ?? 0) + localItem.quantity;
      final mergedFurniture = existing?.furniture ?? localItem.furniture;
      batch.set(cartCollection.doc(localItem.furniture.id), {
        'quantity': mergedQuantity,
        'furniture': _furnitureToMap(mergedFurniture),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> _persistCartForSignedInUser() async {
    final uid = _activeUid;
    if (uid == null) return;

    final cartCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
    final batch = FirebaseFirestore.instance.batch();

    final existingDocs = await cartCollection.get();
    for (final doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    for (final item in state) {
      final docRef = cartCollection.doc(item.furniture.id);
      batch.set(docRef, {
        'quantity': item.quantity,
        'furniture': _furnitureToMap(item.furniture),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();
    } catch (_) {
      // Avoid breaking cart UI if Firestore write rules are still in progress.
    }
  }

  CartItem? _cartItemFromDoc(Map<String, dynamic> data) {
    final quantityRaw = data['quantity'];
    final furnitureRaw = data['furniture'];
    if (furnitureRaw is! Map<String, dynamic>) return null;

    final quantity = quantityRaw is int ? quantityRaw : 1;
    final furniture = Furniture.fromJson(furnitureRaw);
    if (furniture.id.isEmpty) return null;
    return CartItem(furniture: furniture, quantity: quantity);
  }

  Map<String, dynamic> _furnitureToMap(Furniture furniture) {
    return {
      'id': furniture.id,
      'name': furniture.name,
      'price': furniture.price,
      'oldPrice': furniture.oldPrice,
      'brand': furniture.brand,
      'rating': furniture.rating,
      'images': furniture.images,
      'imageUrl': furniture.imageUrl,
      'imagePath': furniture.imagePath,
      'modelURL': furniture.modelURL,
      'material': furniture.material,
      'modelStatus': furniture.modelStatus,
      'modelError': furniture.modelError,
      'primaryColor': furniture.primaryColor,
      'productID': furniture.productID,
      'stockStatus': furniture.stockStatus,
      'furnitureType': furniture.furnitureType,
      'dimensions': furniture.dimensions,
      'availability': furniture.availability,
      'styleTags': furniture.styleTags,
    };
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
