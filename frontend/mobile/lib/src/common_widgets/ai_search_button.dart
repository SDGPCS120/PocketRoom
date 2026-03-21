import 'package:flutter/material.dart';

class AiSearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const AiSearchButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'AI Search',
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
