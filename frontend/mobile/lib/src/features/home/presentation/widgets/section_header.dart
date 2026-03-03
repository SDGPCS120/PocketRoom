import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, this.title = "Sofas"});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
              fontSize: 26, // Keep original size
            ),
          ),

          // This is the filter button 
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFE5D3),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
