import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart'; // Import the new theme file
import '../features/home/data/models/furniture_model.dart';
import '../features/home/presentation/product_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/cart/data/cart_provider.dart';

class ProductCard extends ConsumerWidget {
  final Furniture furniture;

  const ProductCard({super.key, required this.furniture});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingLabel = furniture.rating.isNaN
        ? 'N/A'
        : furniture.rating.toString();
    final priceLabel = furniture.price.isNaN
        ? 'N/A'
        : "LKR ${furniture.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    final brandLabel = furniture.brand.trim().isEmpty
        ? 'N/A'
        : furniture.brand.toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.cardBorder, width: 0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.productCardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(imageUrls: furniture.images),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              AspectRatio(
                aspectRatio: 156.26 / 147,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder, width: 0.6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: furniture.images.isNotEmpty
                        ? Image.network(
                            furniture.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                ),
                                child: Icon(
                                  Icons.chair,
                                  size: 50,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
                          )
                        : const DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                            ),
                            child: Icon(
                              Icons.chair,
                              size: 50,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                furniture.name.trim().isEmpty ? 'N/A' : furniture.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.125, // 18/16
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // Brand and Rating
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ratingLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 1.33,
                          color: AppColors.textRating,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      brandLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        height: 1.67,
                        letterSpacing: 1,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Price and Add to Cart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    priceLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.priceColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(cartProvider.notifier).addItem(furniture);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${furniture.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_shopping_cart,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
