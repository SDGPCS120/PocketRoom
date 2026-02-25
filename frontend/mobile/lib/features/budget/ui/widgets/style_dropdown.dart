import 'package:flutter/material.dart';

class StyleDropdown extends StatelessWidget {
  const StyleDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => onChanged(v ?? value),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}
