import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/product_card.dart';
import '../../data/providers.dart';

class ProductList extends ConsumerWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new FutureProvider. This gives us an AsyncValue.
    final furnitureListAsync = ref.watch(furnitureListProvider);

    // Use .when to handle the different states of the FutureProvider.
    return furnitureListAsync.when(
      // The state while data is loading
      loading: () => const Center(child: CircularProgressIndicator()),
      
      // The state when an error occurs
      error: (error, stackTrace) => Center(
        child: Text('An error occurred: $error'),
      ),

      // The state when data has been successfully fetched
      data: (furnitureItems) {
        // If we have data, we build the list as before.
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: furnitureItems.length,
          itemBuilder: (context, index) {
            return ProductCard(furniture: furnitureItems[index]);
          },
        );
      },
    );
  }
}
