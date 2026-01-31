import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_data.dart';
import '../../data/providers.dart';

class CategoryPills extends ConsumerWidget {
  const CategoryPills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(activeCategoryProvider);

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            label: category,
            isActive: activeCategory == category,
            onTap: () {
              final notifier = ref.read(activeCategoryProvider.notifier);
              // If the tapped category is already active, reset to default.
              if (notifier.state == category) {
                notifier.state = 'Best sellers'; 
              } else {
              // Otherwise, set the new category.
                notifier.state = category;
              }
            },
          );
        },
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the base text style from the current theme for the font family.
    final textStyle = Theme.of(context).textTheme.labelLarge;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8A3D) : const Color(0xFFFFE5D3),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF8A3D).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            // Use the theme's text style, but override the color based on state.
            style: textStyle?.copyWith(
              color: isActive ? Colors.white : const Color(0xFF2D2D2D),
              fontWeight: FontWeight.w600, // Preserve the original weight
            ),
          ),
        ),
      ),
    );
  }
}
