import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/product_card.dart';
import '../providers/home_provider.dart';

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the "fetcher" provider to handle the initial loading/error states.
    final allFurnitureAsync = ref.watch(allFurnitureProvider);

    return allFurnitureAsync.when(
      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => SliverFillRemaining(child: Center(child: Text('Error: $error'))),
      data: (_) {
        // Once the data has loaded, watch the fast "filterer" provider to get
        // the list that should be displayed.
        final filteredList = ref.watch(filteredFurnitureProvider);
        
        // If the filtered list is empty, show a message.
        if (filteredList.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('No items found in this category.')));
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: MediaQuery.of(context).size.width > 600
                ? const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 177 / 253,
                  )
                : const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 177 / 253,
                  ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ProductCard(furniture: filteredList[index]);
              },
              childCount: filteredList.length,
            ),
          ),
        );
      },
    );
  }
}
