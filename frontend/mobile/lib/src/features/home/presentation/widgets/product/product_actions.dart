import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cart/presentation/providers/cart_provider.dart';
import '../../../../auth/presentation/get_started_page.dart';
import '../../../data/models/furniture_model.dart';

class ProductActions extends ConsumerStatefulWidget {
  final Furniture furniture;

  const ProductActions({super.key, required this.furniture});

  @override
  ConsumerState<ProductActions> createState() => _ProductActionsState();
}

class _ProductActionsState extends ConsumerState<ProductActions> {
  int _quantity = 1;

  bool _redirectGuestToGetStarted() {
    final user = FirebaseAuth.instance.currentUser;
    final isSignedIn = user != null && !user.isAnonymous;
    if (isSignedIn) return false;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GetStartedPage()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.furniture;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Quantity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quantity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_quantity > 1) {
                        HapticFeedback.lightImpact();
                        setState(() => _quantity--);
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _quantity++);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Add to cart
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_redirectGuestToGetStarted()) return;
              
              HapticFeedback.mediumImpact();
              for (var i = 0; i < _quantity; i++) {
                ref.read(cartProvider.notifier).addItem(f);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${f.name} ×$_quantity added to cart'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              shadowColor: colorScheme.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 20),
                SizedBox(width: 12),
                Text(
                  'Add to cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // View in AR
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
               HapticFeedback.mediumImpact();
               // AR view logic here
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.view_in_ar_rounded, size: 20),
                SizedBox(width: 12),
                Text(
                  'View in AR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.primary, width: 1.5),
        ),
        child: Icon(icon, size: 16, color: colorScheme.primary),
      ),
    );
  }
}
