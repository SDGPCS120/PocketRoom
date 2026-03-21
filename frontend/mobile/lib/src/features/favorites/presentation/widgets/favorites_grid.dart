import 'package:flutter/material.dart';
import '../../../../common_widgets/product_card.dart';
import '../../../home/data/models/furniture_model.dart';

class FavoritesGrid extends StatelessWidget {
  final List<Furniture> favorites;

  const FavoritesGrid({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 177 / 253,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        return ProductCard(furniture: favorites[index]);
      },
    );
  }
}
