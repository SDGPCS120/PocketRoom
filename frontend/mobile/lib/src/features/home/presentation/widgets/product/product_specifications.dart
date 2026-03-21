import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/furniture_model.dart';

class ProductSpecifications extends StatelessWidget {
  final Furniture furniture;

  const ProductSpecifications({super.key, required this.furniture});

  List<_SpecRow> _parseDimensions(String raw) {
    if (raw.isEmpty || raw == 'N/A') {
      return [const _SpecRow('Dimensions', 'Not specified')];
    }
    final patterns = {
      'Height': RegExp(r'height[:\s]*(\d+)', caseSensitive: false),
      'Width': RegExp(r'width[:\s]*(\d+)', caseSensitive: false),
      'Depth': RegExp(r'depth[:\s]*(\d+)', caseSensitive: false),
      'Length': RegExp(r'length[:\s]*(\d+)', caseSensitive: false),
    };
    final results = <_SpecRow>[];
    for (final entry in patterns.entries) {
      final match = entry.value.firstMatch(raw);
      if (match != null) {
        results.add(_SpecRow(entry.key, '${match.group(1)} cm'));
      }
    }
    if (results.isEmpty) {
      final clean = raw.replaceAll(RegExp(r'[{}]'), '').trim();
      return [_SpecRow('Size', clean.isEmpty ? 'Not specified' : clean)];
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final f = furniture;
    final specs = _parseDimensions(f.dimensions);

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
        const SizedBox(height: 16),
        ...specs.map((s) => _SpecTile(title: s.label, value: s.value)),
        _SpecTile(title: 'Category', value: f.furnitureType),
        if (f.styleTags.isNotEmpty)
          _SpecTile(title: 'Style Tags', value: f.styleTags.join(', ')),
      ],
    );
  }
}

class _SpecRow {
  final String label;
  final String value;
  const _SpecRow(this.label, this.value);
}

class _SpecTile extends StatelessWidget {
  final String title;
  final String value;

  const _SpecTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
