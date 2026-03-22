import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

                    try {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      final apiClient = ref.read(apiClientProvider);
                      final paymentService = ref.read(paymentServiceProvider);

                      // 1. Create Order
                      final orderResponse = await apiClient.post('/orders', data: {
                        'shippingAddressId': 'default-address-id',
                        'billingAddressId': 'default-address-id',
                        'items': cartItems.map((item) => {
                          'productId': item.furniture.id,
                          'productName': item.furniture.name,
                          'quantity': item.quantity,
                          'unitPrice': item.furniture.price,
                        }).toList(),
                        'totalAmount': totalPrice,
                        'currency': 'LKR',
                      });

                      if (orderResponse.statusCode != 200 && orderResponse.statusCode != 201) {
                        throw Exception('Failed to create order');
                      }

                      final orderId = orderResponse.data['orderId'];

                      // 2. Start Payment
                      final success = await paymentService.startPayment(orderId);

                      // Close loading dialog
                      if (context.mounted) Navigator.of(context).pop();

                      if (success) {
                        // 3. Success Feedback
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment Successful! Order Confirmed.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Clear cart or navigate to success page
                          // Assuming we just clear the local state for now if not auto-synced
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment Cancelled or Failed.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Close loading dialog if open
                      if (context.mounted) {
                        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
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
