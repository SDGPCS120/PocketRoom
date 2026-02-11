import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../data/providers.dart';
import '../category_products_page.dart';

class CategoryIconsRow extends ConsumerWidget {
  const CategoryIconsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    // Helper map to associate categories with icons
    // Using standard Material icons as placeholders
    final Map<String, IconData> categoryIcons = {
      'All': Icons.grid_view,
      'Sofas': Icons.chair,
      'Tables': Icons.table_restaurant,
      'Chairs': Icons.chair_alt,
      'Lighting': Icons.light,
      'Beds': Icons.bed, // Assuming 'Beds' might be in mock_data or generic fallback
    };

    return Container(
      height: 100, // Increased height to accommodate icon + text
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final icon = categoryIcons[category] ?? Icons.category; // Fallback icon


          return CategoryIconItem(
            label: category,
            icon: icon,
            // No active state for the home page icons as they are launchers
            isActive: false, 
            onTap: () {
               // Update the provider so the next page knows what to show
               ref.read(activeCategoryProvider.notifier).state = category;
               
               // Navigate to the CategoryProductsPage
               Navigator.push(
                 context,
                 MaterialPageRoute(
                   builder: (context) => const CategoryProductsPage(),
                 ),
               );
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
                color: isActive ? AppColors.primary : Colors.white,
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
                color: isActive ? Colors.white : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
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
