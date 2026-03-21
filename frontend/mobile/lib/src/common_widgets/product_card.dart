import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart'; // Import the new theme file
import '../features/auth/presentation/get_started_page.dart';
import '../features/home/data/models/furniture_model.dart';
import '../features/home/presentation/product_page.dart';
import '../features/home/presentation/vendor_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/favorites/presentation/providers/favorites_provider.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Furniture furniture;

  const ProductCard({super.key, required this.furniture});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isHovered = false;

  bool _redirectGuestToGetStarted() {
    final user = FirebaseAuth.instance.currentUser;
    final isSignedIn = user != null && !user.isAnonymous;
    if (isSignedIn) return false;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GetStartedPage()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final furniture = widget.furniture;
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.any((item) => item.id == furniture.id);

    final ratingLabel = furniture.rating.isNaN
        ? 'N/A'
        : furniture.rating.toString();
    String formatPrice(double p) => "LKR ${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    final priceLabel = furniture.price.isNaN
        ? 'N/A'
        : formatPrice(furniture.price);
    final oldPriceLabel = (furniture.oldPrice != null && !furniture.oldPrice!.isNaN)
        ? formatPrice(furniture.oldPrice!)
        : null;
    final brandLabel = furniture.brand.trim().isEmpty
        ? 'N/A'
        : furniture.brand.toUpperCase();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform:
            _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(
            color: _isHovered ? AppColors.primary : AppColors.cardBorder,
            width: _isHovered ? 1.0 : 0.6,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : AppColors.productCardShadow,
        ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(furniture: furniture),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              AspectRatio(
                aspectRatio: 156.26 / 147,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // border: Border.all(color: AppColors.cardBorder, width: 0.6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorPage(vendorName: furniture.brand),
                          ),
                        );
                      },
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
                          color: AppColors.priceColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Price and Add to Cart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (oldPriceLabel != null)
                        Text(
                          oldPriceLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textSecondary,
                            height: 1.1,
                          ),
                        ),
                      Text(
                        priceLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.priceColor,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_redirectGuestToGetStarted()) {
                        return;
                      }
                      ref.read(favoritesProvider.notifier).toggleFavorite(furniture);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isFavorite 
                              ? '${furniture.name} removed from favorites' 
                              : '${furniture.name} added to favorites'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: isFavorite ? Colors.grey[800] : AppColors.primary,
                        ),
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFavorite 
                          ? AppColors.primary.withValues(alpha: 0.1) 
                          : Colors.transparent,
                        border: Border.all(
                          color: isFavorite ? AppColors.primary : AppColors.cardBorder, 
                          width: 1
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite ? AppColors.primary : Colors.grey,
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
    ),
  );
}
}
