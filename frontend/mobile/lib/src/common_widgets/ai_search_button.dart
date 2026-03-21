import 'package:flutter/material.dart';
import 'glass_container.dart';

class AiSearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const AiSearchButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'AI Search',
      child: GlassContainer(
        borderRadius: 20,
        blur: 10,
        opacity: 0.1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
              semanticLabel: 'AI Search',
            ),
          ),
        ),
      ),
    );
  }
}

