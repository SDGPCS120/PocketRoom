import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/product_card.dart';
import '../../data/providers.dart';

class ProductList extends ConsumerWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final furnitureItems = ref.watch(furnitureProvider);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: furnitureItems.length,
      itemBuilder: (context, index) {
        return ProductCard(furniture: furnitureItems[index]);
      },
    );
  }
}
