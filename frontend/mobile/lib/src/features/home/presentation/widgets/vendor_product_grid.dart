import 'package:flutter/material.dart';
import '../../../../common_widgets/product_card.dart';
import '../../data/models/furniture_model.dart';

class VendorProductGrid extends StatelessWidget {
  final List<Furniture> products;

  const VendorProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No products found for this vendor.')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 177 / 253,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(furniture: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }
}
