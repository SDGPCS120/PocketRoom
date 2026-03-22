import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/common_widgets/product_card.dart';
import 'package:pocketroom/src/features/home/presentation/providers/home_provider.dart';

class ProductSectionList extends ConsumerWidget {
  final String title;
  final List<String> productIds;

  const ProductSectionList({
    super.key,
    required this.title,
    required this.productIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (productIds.isEmpty) return const SizedBox.shrink();

    final allFurnitureAsync = ref.watch(allFurnitureProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280, // Approximate height for ProductCard
          child: allFurnitureAsync.when(
            data: (allFurniture) {
              final recommendations = allFurniture
                  .where((f) => productIds.contains(f.id))
                  .toList();
              
              if (recommendations.isEmpty) return const SizedBox.shrink();

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemCount: recommendations.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 180,
                    child: ProductCard(furniture: recommendations[index]),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text('Failed to load similar products'),
          ),
        ),
      ],
    );
  }
}
