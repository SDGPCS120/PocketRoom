import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../data/models/furniture_model.dart';
import '../../vendor_page.dart';

class ProductDetailsHeader extends StatelessWidget {
  final Furniture furniture;

  const ProductDetailsHeader({super.key, required this.furniture});

  Widget _buildTrustBadge(IconData icon, String label, Color color) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = furniture;
    final hasOldPrice = f.oldPrice != null && !f.oldPrice!.isNaN;
    final hasDescription = f.description.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + Brand + Rating
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VendorPage(vendorName: f.brand),
                      ),
                    ),
                    child: Text(
                      'Brand: ${f.brand.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: colorScheme.primary, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    f.rating.isNaN ? '4.8' : f.rating.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Trust Badges
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTrustBadge(Icons.timer_rounded, 'ONLY 3 LEFT', Colors.red),
              _buildTrustBadge(Icons.handyman_rounded, 'FREE INSTALL', Colors.blue),
              _buildTrustBadge(Icons.verified_rounded, '1-YEAR WARRANTY', Colors.green),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              f.price.toLKR(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                height: 1.0,
              ),
            ),
            if (hasOldPrice && f.oldPrice! > f.price) ...[
              const SizedBox(width: 12),
              Text(
                f.oldPrice!.toLKR(),
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Save ${((1 - f.price / f.oldPrice!) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'or 3 interest-free installments of ${(f.price / 3).toLKR()}',
          style: TextStyle(
            fontSize: 12.5,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        // Description
        if (hasDescription) ...[
          Text(
            f.description,
            style: TextStyle(
              fontSize: 13.5,
              color: colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
