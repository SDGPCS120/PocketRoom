import 'package:flutter/material.dart';

class ProductMaterialsChips extends StatelessWidget {
  final List<String> materials;
  final String selectedMaterial;
  final ValueChanged<String> onMaterialSelected;

  const ProductMaterialsChips({
    super.key,
    required this.materials,
    required this.selectedMaterial,
    required this.onMaterialSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: materials.map((material) {
            final isSelected = material == selectedMaterial;
            return GestureDetector(
              onTap: () => onMaterialSelected(material),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange.shade400 : colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected ? null : Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  material,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
