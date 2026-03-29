import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';
import 'package:pocketroom/src/core/utils/extensions.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import 'package:pocketroom/src/features/home/presentation/vendor_page.dart';
import '../../providers/reviews_provider.dart';

class ProductDetailsHeader extends ConsumerWidget {
  final Furniture furniture;

  const ProductDetailsHeader({super.key, required this.furniture});

  String _formatPrice(double p) => "LKR ${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

  String _formatRawValue(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

  Widget _buildSeparator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '•',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = furniture;
    final colorScheme = Theme.of(context).colorScheme;

    final reviews = ref.watch(reviewsProvider)[f.id] ??
        ref.read(reviewsProvider.notifier).getInitialReviews(f.id);

    final avgRating = reviews.isEmpty 
        ? (f.rating.isNaN ? 4.8 : f.rating)
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    // Pricing Logic
    final hasDiscount = f.oldPrice != null && f.oldPrice! > f.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. BRAND ROW (Tappable)
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => VendorPage(vendorName: f.brand)),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest,
                  image: f.brandLogoUrl.isNotEmpty 
                      ? DecorationImage(image: NetworkImage(f.brandLogoUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: f.brandLogoUrl.isEmpty 
                    ? Icon(Icons.storefront_rounded, size: 14, color: colorScheme.primary) 
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                f.brand,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. PRODUCT TITLE
        Text(
          f.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        
        // 3. CONSOLIDATED INFO ROW
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: Colors.orange.shade400, size: 24),
            const SizedBox(width: 6),
            Text(
              avgRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w800, 
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '·  ${reviews.length} reviews',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w500, 
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                f.availability.toLowerCase().contains('only') ? f.availability : 'In Stock',
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w700, 
                  color: f.availability.toLowerCase().contains('only') ? Colors.orange.shade800 : Colors.green.shade700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '· Delivery in 3–5 days',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500, 
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 4. PRICE SECTION
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatPrice(f.price),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.orange.shade400, // Matching the orange price text
                    letterSpacing: -0.5,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    _formatPrice(f.oldPrice!),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'or 3x LKR ${_formatRawValue(f.price / 3)} with Interest Free Plans',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
        
        // Style Tags (Secondary Pills)
        if (f.styleTags.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: f.styleTags.take(3).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
