import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/product_card.dart';
import '../../data/providers.dart';

class ProductList extends ConsumerWidget {
  final bool isHorizontal;
  const ProductList({super.key, this.isHorizontal = false});

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

        if (isHorizontal) {
          final horizontalPadding = 20.0;
          final itemSpacing = 16.0;
          final screenWidth = MediaQuery.of(context).size.width;
          final availableWidth = screenWidth - (horizontalPadding * 2);
          // Calculate cardWidth to show ~2.14 items in the viewport (2 and 1/7)
          final cardWidth = (availableWidth - (itemSpacing * 2)) / 2.14;

          return SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == filteredList.length - 1 ? 0 : itemSpacing,
                      ),
                      child: SizedBox(
                        width: cardWidth,
                        child: ProductCard(furniture: filteredList[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
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
