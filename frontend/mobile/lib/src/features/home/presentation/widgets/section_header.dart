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

          // This is the sort/filter button 
          PopupMenuButton<SortOrder>(
            initialValue: currentSortOrder,
            onSelected: (SortOrder order) {
              ref.read(sortOrderProvider.notifier).state = order;
            },
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white,
            elevation: 4,
            itemBuilder: (context) => [
              _buildPopupOption(SortOrder.none, 'Relevance', Icons.reorder),
              _buildPopupOption(SortOrder.priceAsc, 'Price: Low to High', Icons.arrow_upward),
              _buildPopupOption(SortOrder.priceDesc, 'Price: High to Low', Icons.arrow_downward),
              _buildPopupOption(SortOrder.ratingDesc, 'Rating: High to Low', Icons.star),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5D3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentSortOrder == SortOrder.none ? Icons.tune : Icons.sort,
                size: 20,
                color: currentSortOrder == SortOrder.none ? Colors.black : const Color(0xFFFF8A3D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<SortOrder> _buildPopupOption(SortOrder order, String label, IconData icon) {
    return PopupMenuItem<SortOrder>(
      value: order,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF8A3D)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
