import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/furniture_model.dart';

class ProductSpecifications extends StatelessWidget {
  final Furniture furniture;

  const ProductSpecifications({super.key, required this.furniture});

  @override
  Widget build(BuildContext context) {
    final f = furniture;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specifications',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _SpecSection(
          title: 'Dimensions',
          bullets: [f.dimensions],
        ),
        _SpecSection(
          title: 'Category',
          bullets: [f.furnitureType],
        ),
        if (f.styleTags.isNotEmpty)
          _SpecSection(
            title: 'Style Tags',
            bullets: f.styleTags,
          ),
      ],
    );
  }
}

class _SpecSection extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _SpecSection({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
