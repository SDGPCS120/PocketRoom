import 'package:flutter/material.dart';

class BudgetSlider extends StatelessWidget {
  const BudgetSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toInt()}'),
            Text('${max.toInt()}'),
          ],
        )
      ],
    );
  }
}
