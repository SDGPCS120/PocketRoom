import 'package:flutter/material.dart';

class ColorPickerRow extends StatelessWidget {
  const ColorPickerRow({
    super.key,
    required this.colors,
    required this.selected,
    required this.onToggle,
  });

  final List<_ColorOption> colors;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 12,
      children: colors.map((c) {
        final isOn = selected.contains(c.name);
        return InkWell(
          onTap: () => onToggle(c.name),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.color,
                  border: Border.all(
                    color: isOn 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isOn ? 3 : 1,
                  ),
                ),
                child: isOn
                    ? Icon(
                        Icons.check, 
                        color: c.color.computeLuminance() > 0.5 
                            ? Colors.black 
                            : Colors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                c.label, 
                style: TextStyle(
                  fontSize: 12, 
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ColorOption {
  const _ColorOption(this.name, this.label, this.color);
  final String name;  // value we send to backend
  final String label; // shown in UI
  final Color color;
}

/// helper you can reuse from the page
List<_ColorOption> defaultBudgetColors() => const [
  _ColorOption('oak', 'Oak', Color(0xFFCFA56A)),
  _ColorOption('charcoal', 'Charcoal', Color(0xFF2F343B)),
  _ColorOption('navy', 'Navy', Color(0xFF0B1E6D)),
  _ColorOption('white', 'White', Color(0xFFFFFFFF)),
  _ColorOption('sage', 'Sage', Color(0xFFA7B8A7)),
];
