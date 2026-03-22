import 'package:flutter/material.dart';
import '../../../data/models/furniture_model.dart';

class ProductSpecifications extends StatelessWidget {
  final Furniture furniture;

  const ProductSpecifications({super.key, required this.furniture});

  @override
  Widget build(BuildContext context) {
    final f = furniture;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // 1. Dimensions Group
        _buildSectionTitle(context, 'Dimensions'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: _parseDimensions(f.dimensions).map((s) => _SpecRowWidget(label: s.label, value: s.value)).toList(),
              ),
            ),
            const SizedBox(width: 24),
            // Dimension Diagram Placeholder/Illustration
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/furniture_dimension_diagram.png', // Fallback to asset if exists
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.straighten_rounded,
                    size: 32,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 2. Materials Group
        _buildSectionTitle(context, 'Materials'),
        _SpecRowWidget(
          label: f.materials.length > 1 ? 'Materials' : 'Material',
          value: f.materials.isNotEmpty ? f.materials.join(', ') : (f.material.isNotEmpty ? f.material : 'Premium Finish'),
        ),
        const SizedBox(height: 32),

        // 3. Other Group
        _buildSectionTitle(context, 'Other Details'),
        _SpecRowWidget(label: 'Category', value: f.furnitureType),
        if (f.styleTags.isNotEmpty)
          _SpecRowWidget(label: 'Style Tags', value: f.styleTags.join(', ')),
        _SpecRowWidget(label: 'Assembly', value: 'Partially Required'),
        _SpecRowWidget(label: 'Guarantee', value: '2 Years Manufacturer'),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  List<_SpecData> _parseDimensions(String raw) {
    if (raw.isEmpty || raw == 'N/A') {
      return [const _SpecData('Size', 'Standard')];
    }
    final patterns = {
      'Height': RegExp(r'height[:\s]*(\d+)', caseSensitive: false),
      'Width': RegExp(r'width[:\s]*(\d+)', caseSensitive: false),
      'Depth': RegExp(r'depth[:\s]*(\d+)', caseSensitive: false),
      'Length': RegExp(r'length[:\s]*(\d+)', caseSensitive: false),
    };
    final results = <_SpecData>[];
    for (final entry in patterns.entries) {
      final match = entry.value.firstMatch(raw);
      if (match != null) {
        results.add(_SpecData(entry.key, '${match.group(1)} cm'));
      }
    }
    if (results.isEmpty) {
      final clean = raw.replaceAll(RegExp(r'[{}]'), '').trim();
      return [_SpecData('Size', clean.isEmpty ? 'Standard' : clean)];
    }
    return results;
  }
}

class _SpecData {
  final String label;
  final String value;
  const _SpecData(this.label, this.value);
}

class _SpecRowWidget extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRowWidget({required this.label, required this.value});

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
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
