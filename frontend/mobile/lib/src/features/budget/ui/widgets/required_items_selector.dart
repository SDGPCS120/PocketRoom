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
              color: isOn ? const Color(0xFFF8E9D8) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOn ? const Color(0xFFD29A5A) : const Color(0xFFE0E0E0),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(blurRadius: 8, color: Color(0x11000000), offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconFor(name),
                  size: 28,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                Text(
                  _label(name),
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
