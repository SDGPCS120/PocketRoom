import 'package:flutter/material.dart';

class RequiredItemsSelector extends StatelessWidget {
  const RequiredItemsSelector({
    super.key,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  final List<String> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((name) {
        final isOn = selected.contains(name);
        return InkWell(
          onTap: () => onToggle(name),
          child: Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isOn ? const Color(0xFFF8E9D8) : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOn ? const Color(0xFFD29A5A) : colorScheme.outlineVariant,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8, 
                  color: colorScheme.shadow.withValues(alpha: 0.07), 
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconFor(name),
                  size: 28,
                  color: isOn ? const Color(0xFFD29A5A) : colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                Text(
                  _label(name),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOn ? const Color(0xFFD29A5A) : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  static IconData _iconFor(String name) {
    switch (name) {
      case 'sofa':
        return Icons.weekend;
      case 'bed':
        return Icons.bed;
      case 'wardrobe':
        return Icons.door_sliding;
      case 'chair':
        return Icons.chair;
      default:
        return Icons.category;
    }
  }

  static String _label(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}
