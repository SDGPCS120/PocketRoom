import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../AR/ar_view_page.dart';

class CartSummaryBottomBar extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onCheckout;

  const CartSummaryBottomBar({
    super.key,
    required this.totalPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                totalPrice.toLKR(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCheckout,
            style: AppButtonStyles.primaryButton.copyWith(
              minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
            ),
            child: const Text('Checkout'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ArViewPage(),
                ),
              );
            },
            style: AppButtonStyles.outlinedButton.copyWith(
              minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
              side: WidgetStateProperty.all(const BorderSide(color: AppColors.primary)),
              foregroundColor: WidgetStateProperty.all(AppColors.primary),
            ),
            child: const Text('View in AR'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
