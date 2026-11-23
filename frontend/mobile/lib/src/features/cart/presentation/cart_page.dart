import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/cart_item.dart';
import 'providers/cart_provider.dart';
import 'widgets/cart_app_bar.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary_bottom_bar.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/payment_service.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _checkoutBusy = false;

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _checkout(List<CartItem> cartItems) async {
    if (_checkoutBusy || cartItems.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      _message('Sign in to check out.');
      return;
    }

    _checkoutBusy = true;
    final apiClient = ref.read(apiClientProvider);
    final paymentService = ref.read(paymentServiceProvider);
    try {
      var pending = paymentService.pendingCheckouts[user.uid];
      if (pending == null) {
        final addresses = await apiClient.get(
          '/addresses',
          queryParameters: {'isDefault': 'true'},
        );
        final envelope = addresses.data as Map<String, dynamic>;
        final rows = envelope['data'] as List<dynamic>;
        final addressId = rows.isEmpty
            ? 'mock-address'
            : (rows.first as Map<String, dynamic>)['id'] as String;
        if (!mounted || FirebaseAuth.instance.currentUser?.uid != user.uid) {
          return;
        }
        final orderResponse = await apiClient.post(
          '/orders',
          data: {
            'shippingAddressId': addressId,
            'billingAddressId': addressId,
            'items': cartItems
                .map(
                  (item) => {
                    'productId': item.furniture.id,
                    'productName': item.furniture.name,
                    'quantity': item.quantity,
                    'unitPrice': item.furniture.price,
                  },
                )
                .toList(),
            'currency': 'LKR',
          },
        );
        final orderEnvelope = orderResponse.data as Map<String, dynamic>;
        final order = orderEnvelope['data'] as Map<String, dynamic>;
        pending = PendingCheckout(order['orderId'] as String, {
          for (final item in cartItems) item.furniture.id: item.quantity,
        });
        paymentService.pendingCheckouts[user.uid] = pending;
      }

      final status = await paymentService.paymentStatus(pending.orderId);
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != user.uid) {
        return;
      }
      if (status == 'SUCCESS') {
        paymentService.pendingCheckouts.remove(user.uid);
        ref
            .read(cartProvider.notifier)
            .removePurchasedItems(pending.quantities);
        _message('Payment verified. Your order is confirmed.');
        return;
      }
      if (status == 'FAILED' || status == 'CANCELLED') {
        paymentService.pendingCheckouts.remove(user.uid);
        _message('Payment did not complete. Your cart is ready to try again.');
        return;
      }
      final url = await paymentService.prepareCheckout(pending.orderId);
      if (!mounted || FirebaseAuth.instance.currentUser?.uid != user.uid) {
        return;
      }
      if (url == null) {
        _message(
          'Payment is pending. Return here and tap Checkout to check its status.',
        );
        return;
      }
      final opened = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('PayHere sandbox checkout'),
          content: const Text(
            'Complete payment in your browser, then return here to check its status.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await paymentService.openCheckout(url);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                } catch (_) {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(false);
                  }
                  _message('Unable to open the checkout link. Try again.');
                }
              },
              child: const Text('Open PayHere'),
            ),
          ],
        ),
      );
      if (opened == true) {
        _message('Tap Checkout again after returning from PayHere.');
      }
    } catch (_) {
      _message('Checkout is unavailable. Your cart has been kept.');
    } finally {
      _checkoutBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onCheckout: () => _checkout(cartItems),
                ),
              ],
            ),
    );
  }
}
