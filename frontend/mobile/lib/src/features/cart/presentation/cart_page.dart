import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'widgets/cart_app_bar.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary_bottom_bar.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/payment_service.dart';

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
                  onCheckout: () async {
                    if (cartItems.isEmpty) return;

                    // Ensure user is logged in
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You must be logged in to checkout.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    try {
                      final apiClient = ref.read(apiClientProvider);
                      final paymentService = ref.read(paymentServiceProvider);

                      // ── Step 1: Create Order ───────────────────────────────
                      // shippingAddressId is a plain string—no FK validation.
                      // Using 'mock-address' so checkout works without a saved address.
                      final orderResponse = await apiClient.post('/orders', data: {
                        'shippingAddressId': 'mock-address',
                        'billingAddressId': 'mock-address',
                        'items': cartItems.map((item) => {
                              'productId': item.furniture.id,
                              'productName': item.furniture.name,
                              'quantity': item.quantity,
                              'unitPrice': item.furniture.price,
                              'itemTotal': item.furniture.price * item.quantity,
                            }).toList(),
                        'totalAmount': totalPrice,
                        'currency': 'LKR',
                      });

                      // Unwrap { success, data, meta } envelope
                      final orderEnvelope =
                          orderResponse.data as Map<String, dynamic>?;
                      final orderData =
                          orderEnvelope?['data'] as Map<String, dynamic>?;
                      final orderId = orderData?['orderId'] as String?;

                      if (orderId == null || orderId.isEmpty) {
                        throw Exception(
                            'Order was created but no orderId was returned.');
                      }

                      // ── Step 2: Launch PayHere sandbox payment ─────────────
                      final success = await paymentService.startPayment(orderId);

                      // Dismiss loading
                      if (context.mounted) Navigator.of(context).pop();

                      if (success) {
                        // Clear the cart after successful payment
                        final itemIds =
                            cartItems.map((i) => i.furniture.id).toList();
                        for (final id in itemIds) {
                          ref.read(cartProvider.notifier).removeItem(id);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('🎉 Payment Successful! Order Confirmed.'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Payment cancelled or failed. Your cart is unchanged.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checkout error: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
    );
  }
}
