import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';

class SectionHeader extends ConsumerWidget {
  final String title;
  const SectionHeader({super.key, this.title = "Sofas"});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentSortOrder = ref.watch(sortOrderProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
              fontSize: 26, // Keep original size
            ),
          ),

          // This is the filter button 
          IconButton(
            onPressed: () {
              _showSortBottomSheet(context, ref, currentSortOrder);
            },
            icon: Icon(
              currentSortOrder == SortOrder.none ? Icons.tune : Icons.sort,
              size: 20,
              color: currentSortOrder == SortOrder.none ? Colors.black : const Color(0xFFFF8A3D),
            ),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFE5D3),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context, WidgetRef ref, SortOrder currentOrder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Sort By',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSortOption(
                context,
                ref,
                'Relevance (Default)',
                SortOrder.none,
                currentOrder == SortOrder.none,
              ),
              _buildSortOption(
                context,
                ref,
                'Price: Low to High',
                SortOrder.priceAsc,
                currentOrder == SortOrder.priceAsc,
              ),
              _buildSortOption(
                context,
                ref,
                'Price: High to Low',
                SortOrder.priceDesc,
                currentOrder == SortOrder.priceDesc,
              ),
              _buildSortOption(
                context,
                ref,
                'Rating: High to Low',
                SortOrder.ratingDesc,
                currentOrder == SortOrder.ratingDesc,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    SortOrder order,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? const Color(0xFFFF8A3D) : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFFFF8A3D) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        ref.read(sortOrderProvider.notifier).state = order;
        Navigator.pop(context);
      },
    );
  }
}
