import 'package:flutter/material.dart';

class ProductQuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final int? maxQuantity;

  const ProductQuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.maxQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuantityButton(
              icon: Icons.remove,
              onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
              colorScheme: colorScheme,
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                quantity.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            _buildQuantityButton(
              icon: Icons.add,
              onPressed: (maxQuantity == null || quantity < maxQuantity!) 
                  ? () => onQuantityChanged(quantity + 1) 
                  : null,
              colorScheme: colorScheme,
            ),
            if (maxQuantity != null && maxQuantity! <= 5) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade900),
                    const SizedBox(width: 6),
                    Text(
                      'Only $maxQuantity left in stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required ColorScheme colorScheme,
  }) {
    final isDisabled = onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled 
                  ? colorScheme.outline.withValues(alpha: 0.1) 
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 1.5,
            ),
            color: isDisabled 
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) 
                : colorScheme.surface,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDisabled 
                ? colorScheme.onSurface.withValues(alpha: 0.3) 
                : colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
