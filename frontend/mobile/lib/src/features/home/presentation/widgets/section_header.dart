import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';

class SectionHeader extends ConsumerWidget {
  final String title;
  final Widget? trailing;
  final bool showSort;

  const SectionHeader({
    super.key,
    this.title = "Sofas",
    this.trailing,
    this.showSort = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentSortOrder = ref.watch(sortOrderProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
          ),

          if (showSort)
            PopupMenuButton<SortOrder>(
            initialValue: currentSortOrder,
            onSelected: (SortOrder order) {
              ref.read(sortOrderProvider.notifier).state = order;
            },
            offset: const Offset(0, 45),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Theme.of(context).colorScheme.surface,
            elevation: 4,
            itemBuilder: (context) => [
              _buildPopupOption(context, SortOrder.none, 'Relevance', Icons.reorder),
              _buildPopupOption(context, 
                  SortOrder.priceAsc, 'Price: Low to High', Icons.arrow_upward),
              _buildPopupOption(context, SortOrder.priceDesc, 'Price: High to Low',
                  Icons.arrow_downward),
              _buildPopupOption(context, 
                  SortOrder.ratingDesc, 'Rating: High to Low', Icons.star),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentSortOrder == SortOrder.none ? Icons.tune : Icons.sort,
                size: 20,
                color: currentSortOrder == SortOrder.none
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<SortOrder> _buildPopupOption(
      BuildContext context, SortOrder order, String label, IconData icon) {
    return PopupMenuItem<SortOrder>(
      value: order,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

