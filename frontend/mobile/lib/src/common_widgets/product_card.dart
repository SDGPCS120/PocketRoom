import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart'; // Import the new theme file
import '../features/home/data/models/furniture_model.dart';
import '../features/home/presentation/product_page.dart';

class ProductCard extends StatelessWidget {
  final Furniture furniture;

  const ProductCard({super.key, required this.furniture});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                imageUrls: furniture.images,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            // Use the centralized gradient
            gradient: AppColors.cardGradient,
          ),
          child: Row(
            children: [
              Container(
                width: 140,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: furniture.images.isNotEmpty
                      ? Image.network(
                          furniture.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.secondary, // Use centralized color
                              child: const Icon(Icons.chair, size: 50, color: AppColors.textSecondary),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.secondary, // Use centralized color
                          child: const Icon(Icons.chair, size: 50, color: AppColors.textSecondary),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          furniture.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary, // Use centralized color
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "LKR ${furniture.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, // Use centralized color
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Brand: ${furniture.brand}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary, // Use centralized color
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.primary, // Use centralized color
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          furniture.rating.toString(),
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary, // Use centralized color
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
