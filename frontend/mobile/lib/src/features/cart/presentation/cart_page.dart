import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'widgets/cart_app_bar.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary_bottom_bar.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.read(cartProvider.notifier).totalPrice;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CartAppBar(),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'No Orders to show',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        item: item,
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .incrementQuantity(item.furniture.id),
                        onDecrement: () => ref
                            .read(cartProvider.notifier)
                            .decrementQuantity(item.furniture.id),
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .removeItem(item.furniture.id),
                      );
                    },
                  ),
                ),
                CartSummaryBottomBar(
                  totalPrice: totalPrice,
                  onCheckout: () {
                    // TODO: Implement checkout
                  },
                ),
              ],
            ),
    );
  }
}
