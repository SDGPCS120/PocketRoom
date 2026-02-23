import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import './models/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
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
  }

  void removeItem(int furnitureId) {
    state = state.where((item) => item.furniture.id != furnitureId).toList();
  }

  void incrementQuantity(int furnitureId) {
    final index = state.indexWhere((item) => item.furniture.id == furnitureId);
    if (index != -1) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(index + 1),
      ];
    }
  }

  void decrementQuantity(int furnitureId) {
    final index = state.indexWhere((item) => item.furniture.id == furnitureId);
    if (index != -1) {
      final item = state[index];
      if (item.quantity > 1) {
        state = [
          ...state.sublist(0, index),
          item.copyWith(quantity: item.quantity - 1),
          ...state.sublist(index + 1),
        ];
      } else {
        removeItem(furnitureId);
      }
    }
  }

  double get totalPrice {
    return state.fold(0, (sum, item) => sum + (item.furniture.price * item.quantity));
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
