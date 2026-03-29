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
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        
        // 1. Dimensions Card
        _buildCard(
          context: context,
          icon: Icons.straighten_rounded,
          title: 'Dimensions',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: _parseDimensions(f.dimensions).map((s) => _buildTableRow(context, s.label, s.value)).toList(),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 80,
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Center(
                  child: Icon(
                    Icons.chair_alt_rounded,
                    size: 48,
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Materials Card
        _buildCard(
          context: context,
          icon: Icons.texture_rounded,
          title: 'Materials',
          child: Column(
            children: [
              _buildTableRow(context, 'Material', f.materials.isNotEmpty ? f.materials.join(', ') : (f.material.isNotEmpty ? f.material : 'Mesh and Steel')),
              _buildTableRow(context, 'Seat', 'High-Density Foam'),
              _buildTableRow(context, 'Finish', 'Matte Powder Coat', isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 3. General Card
        _buildCard(
          context: context,
          icon: Icons.info_outline_rounded,
          title: 'General',
          child: Column(
            children: [
              _buildTableRow(context, 'Category', f.furnitureType.trim().isEmpty ? 'N/A' : f.furnitureType),
              _buildTableRow(context, 'Brand', f.brand.trim().isEmpty ? 'N/A' : f.brand),
              _buildTableRow(context, 'Weight Capacity', '120 kg'),
              _buildTableRow(context, 'Assembly', 'Required (30 min)', isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 4. Delivery, Returns & Warranty Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 4, height: 18, color: Colors.orange.shade400),
            const SizedBox(width: 8),
            Text(
              'Delivery, Returns & Warranty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildDeliveryRow(context, Icons.local_shipping_outlined, 'Islandwide delivery', 'Estimated time: 3-5 working days'),
              _buildDivider(context),
              _buildDeliveryRow(context, Icons.replay_rounded, '7-day return policy', 'Easy returns if unused and in original condition'),
              _buildDivider(context),
              _buildDeliveryRow(context, Icons.verified_user_outlined, '1-year warranty', 'Covers manufacturing defects'),
              _buildDivider(context),
              _buildDeliveryRow(context, Icons.build_outlined, 'Assembly required: Yes', 'Free installation available'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.orange.shade600),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, String label, String value, {bool isLast = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) _buildDivider(context),
      ],
    );
  }

  Widget _buildDeliveryRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: Colors.orange.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  List<_SpecData> _parseDimensions(String raw) {
    if (raw.isEmpty || raw == 'N/A') {
      return [const _SpecData('Size', 'Standard')];
    }
    final patterns = {
      'Height': RegExp(r'(?:height|h)[:\s]*([\d\.]+)', caseSensitive: false),
      'Width': RegExp(r'(?:width|w)[:\s]*([\d\.]+)', caseSensitive: false),
      'Length': RegExp(r'(?:length|l)[:\s]*([\d\.]+)', caseSensitive: false),
      'Depth': RegExp(r'(?:depth|d)[:\s]*([\d\.]+)', caseSensitive: false),
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
