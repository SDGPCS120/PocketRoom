import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';

class CartItem {
  final Furniture furniture;
  final int quantity;

  CartItem({
    required this.furniture,
    this.quantity = 1,
  });

  CartItem copyWith({
    Furniture? furniture,
    int? quantity,
  }) {
    return CartItem(
      furniture: furniture ?? this.furniture,
      quantity: quantity ?? this.quantity,
    );
  }
}
