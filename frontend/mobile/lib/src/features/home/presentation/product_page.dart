import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/furniture_model.dart';
import 'widgets/product/product_image_carousel.dart';
import 'widgets/product/product_details_header.dart';
import 'widgets/product/product_actions.dart';
import 'widgets/product/product_specifications.dart';
import 'widgets/product/product_reviews_section.dart';
import 'widgets/product/product_add_review_form.dart';

class ProductPage extends StatelessWidget {
  final Furniture furniture;

  const ProductPage({super.key, required this.furniture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImageCarousel(furniture: furniture),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductDetailsHeader(furniture: furniture),
                          const SizedBox(height: 14),
                          ProductActions(furniture: furniture),
                          const SizedBox(height: 32),
                          ProductSpecifications(furniture: furniture),
                          const SizedBox(height: 32),
                          ProductReviewsSection(productId: furniture.id),
                          const SizedBox(height: 24),
                          ProductAddReviewForm(productId: furniture.id),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.white.withValues(alpha: 0.85),
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back,
                        size: 22, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
