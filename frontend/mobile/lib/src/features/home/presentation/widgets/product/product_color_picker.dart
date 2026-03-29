import 'package:flutter/material.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';

class ProductColorPicker extends StatelessWidget {
  final List<ProductColor> colors;
  final String selectedColor; // This is the color name
  final ValueChanged<String> onColorSelected;

  const ProductColorPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: 'Color: '),
              TextSpan(
                text: selectedColor,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final colorObj = colors[index];
              final isSelected = colorObj.name == selectedColor;
              final swatchColor = colorObj.toDisplayColor();

              return GestureDetector(
                onTap: () => onColorSelected(colorObj.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.orange.shade400 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: swatchColor,
                      shape: BoxShape.circle,
                      border: isSelected ? null : Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
