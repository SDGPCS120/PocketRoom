import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_data.dart'; 
import '../providers/home_provider.dart'; 
import '../category_products_page.dart';

class CategoryIconsRow extends ConsumerWidget {
  const CategoryIconsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


// We don't really need to watch the provider here since we don't show active state on home page
    // final activeCategory = ref.watch(selectedFurnitureTypeProvider);
    // Using standard Material icons as placeholders
    final Map<String, IconData> categoryIcons = {
      'All': Icons.grid_view,
      'Sofa': Icons.chair,
      'Table': Icons.table_restaurant,
      'Chair': Icons.chair_alt,
      'Lamp': Icons.light,
    };

    return Container(
      height: 100, // Increased height to accommodate icon + text
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: furnitureTypes.length,
        itemBuilder: (context, index) {
          final category = furnitureTypes[index];
          final icon = categoryIcons[category] ?? Icons.category; // Fallback icon


          return CategoryIconItem(
            label: category,
            icon: icon,
            // No active state for the home page icons as they are launchers
            isActive: false, 
            onTap: () {
               // Set the Furniture Type (e.g. Sofa, Chair)
               ref.read(selectedFurnitureTypeProvider.notifier).state = category;
               
               // Reset the General Category filter to default
               ref.read(selectedGeneralCategoryProvider.notifier).state = 'Best sellers';
               
               // Navigate to the CategoryProductsPage
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => const CategoryProductsPage(),
                 ),
               ).then((_) {
                 // Reset the Furniture Type and General Category when returning to Home
                 ref.read(selectedFurnitureTypeProvider.notifier).state = 'All';
                 ref.read(selectedGeneralCategoryProvider.notifier).state = 'Best sellers';
               });
            },
          );
        },
      ),
    );
  }
}

class CategoryIconItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryIconItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive ? colorScheme.primary : colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? colorScheme.onPrimary : colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
