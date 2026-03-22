import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../home/data/models/furniture_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/data/models/cart_item.dart';
import '../../../cart/presentation/cart_page.dart';

class BudgetResultPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> result;

  const BudgetResultPage({super.key, required this.result});

  @override
  ConsumerState<BudgetResultPage> createState() => _BudgetResultPageState();
}

class _BudgetResultPageState extends ConsumerState<BudgetResultPage> {
  int _currentIndex = 0;
  // Map of item unique ID -> quantity
  final Map<String, int> _itemQuantities = {};

  @override
  void initState() {
    super.initState();
    _resetQuantities();
  }

  void _resetQuantities() {
    _itemQuantities.clear();
    final bundles = (widget.result['bundles'] as List?) ?? [];
    if (bundles.isNotEmpty && _currentIndex < bundles.length) {
      final currentBundle = bundles[_currentIndex] as Map<String, dynamic>;
      final required = (currentBundle['requiredBundle'] as List?) ?? [];
      final optional = (currentBundle['optionalBundle'] as List?) ?? [];
      for (final it in [...required, ...optional]) {
        final id = _getItemId(it);
        _itemQuantities[id] = 1;
      }
    }
  }

  String _getItemId(Map<String, dynamic> item) {
    final data = (item['product'] is Map) ? item['product'] : item;
    return (data['id'] ?? data['productID'] ?? item.hashCode).toString();
  }

  void _addToCart(List<dynamic> items) {
    final List<CartItem> cartItems = [];
    for (final it in items) {
      final itemData = (it['product'] is Map) ? Map<String, dynamic>.from(it['product']) : it;
      final furniture = Furniture.fromJson({
        ...itemData,
        'furnitureType': it['category'] ?? itemData['category'] ?? itemData['furnitureType'] ?? "-",
      });
      final qty = _itemQuantities[_getItemId(it)] ?? 1;
      cartItems.add(CartItem(furniture: furniture, quantity: qty));
    }

    ref.read(cartProvider.notifier).addItems(cartItems);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${cartItems.length} items added to cart!"),
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: "View Cart",
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          },
        ),
      ),
    );

    // Force hide after 2 seconds just in case the system timer fails
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final bool ok = widget.result['ok'] == true;
    final reason = widget.result['reason'];
    final totalBudget = widget.result['totalBudget'] as num? ?? 0;
    final bundles = (widget.result['bundles'] as List?) ?? [];

    Map<String, dynamic>? currentBundle;
    if (bundles.isNotEmpty) {
      currentBundle = bundles[_currentIndex] as Map<String, dynamic>?;
    }

    final List<dynamic> requiredBundle = (currentBundle?['requiredBundle'] as List?) ?? [];
    final List<dynamic> optionalBundle = (currentBundle?['optionalBundle'] as List?) ?? [];
    final items = [...requiredBundle, ...optionalBundle];

    // Calculate dynamic totals
    double currentTotalCost = 0;
    for (final it in items) {
      final data = (it['product'] is Map) ? it['product'] : it;
      final price = (data['price'] as num? ?? 0).toDouble();
      final qty = _itemQuantities[_getItemId(it)] ?? 1;
      currentTotalCost += price * qty;
    }
    final currentRemaining = totalBudget - currentTotalCost;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text("Budget Result", style: AppTextStyles.appBarTitle(context)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bundles.length > 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bundle ${_currentIndex + 1} of ${bundles.length}", 
                      style: AppTextStyles.sectionTitle(context),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex = (_currentIndex + 1) % bundles.length;
                          _resetQuantities();
                        });
                      },
                      icon: const Icon(Icons.skip_next),
                      label: const Text("Next Bundle"),
                      style: AppButtonStyles.primaryButton(context).copyWith(
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
              ],
              _SummaryCard(
                ok: ok,
                totalBudget: totalBudget,
                totalCost: currentTotalCost,
                remaining: currentRemaining,
                reason: reason,
              ),
              const SizedBox(height: 20),

              Text(
                "Bundle Items",
                style: AppTextStyles.sectionTitle(context).copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          ok ? "No items returned." : (reason ?? "No bundle could be generated."),
                          style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index] as Map<String, dynamic>;
                                final id = _getItemId(item);
                                return _ProductItem(
                                  product: item,
                                  quantity: _itemQuantities[id] ?? 1,
                                  onQuantityChanged: (newQty) {
                                    setState(() {
                                      _itemQuantities[id] = newQty;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          if (items.isNotEmpty && ok) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: () => _addToCart(items),
                                icon: const Icon(Icons.shopping_bag_outlined),
                                label: const Text("ADD THIS BUNDLE TO CART"),
                                style: AppButtonStyles.primaryButton(context),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final bool ok;
  final num totalBudget;
  final num totalCost;
  final num remaining;
  final String? reason;

  const _SummaryCard({
    required this.ok,
    required this.totalBudget,
    required this.totalCost,
    required this.remaining,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bgColor = ok ? colorScheme.surface : colorScheme.errorContainer.withAlpha(25);
    final textColor = ok ? colorScheme.onSurface : colorScheme.error;
    final borderColor = ok ? colorScheme.primary.withAlpha(128) : colorScheme.error.withAlpha(128);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: borderColor),
        boxShadow: AppColors.productCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.check_circle : Icons.error, color: textColor, size: 24),
              const SizedBox(width: 8),
              Text(
                ok ? "Bundle generated" : "Generation failed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryLine(label: "Total budget", value: totalBudget.toLKR(), textColor: textColor),
          _SummaryLine(label: "Total cost", value: totalCost.toLKR(), textColor: textColor),
          _SummaryLine(label: "Remaining", value: remaining.toLKR(), textColor: textColor, isHighlight: true),
          if (!ok && reason != null) ...[
            const Divider(height: 20),
            Text("Reason: $reason", style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final bool isHighlight;

  const _SummaryLine({
    required this.label,
    required this.value,
    required this.textColor,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textColor.withAlpha(204), fontSize: 14)),
          Text(
            value, 
            style: TextStyle(
              color: textColor, 
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlight ? 16 : 14,
            )
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _ProductItem({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final itemData = (product['product'] is Map) 
        ? Map<String, dynamic>.from(product['product']) 
        : product;

    final furniture = Furniture.fromJson({
      ...itemData,
      'furnitureType': product['category'] ?? itemData['category'] ?? itemData['furnitureType'] ?? "-",
    });

    final name = furniture.name.trim().isEmpty ? "Unknown" : furniture.name;
    final price = furniture.price.isNaN ? 0.0 : furniture.price;
    final furnitureType = furniture.furnitureType.trim().isEmpty ? "-" : furniture.furnitureType;
    final brand = furniture.brand.trim().isEmpty ? "PocketRoom" : furniture.brand;
    final rating = furniture.rating.isNaN ? 4.0 : furniture.rating;
    
    final imageUrl = furniture.images.isNotEmpty ? furniture.images.first : null;

    String formatPrice(double p) => "LKR ${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: colorScheme.outline.withAlpha(51)),
        boxShadow: AppColors.productCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: colorScheme.secondary.withAlpha(51),
                        child: Icon(Icons.chair, size: 40, color: colorScheme.onSurfaceVariant.withAlpha(128)),
                      ),
                    )
                  : Container(
                      color: colorScheme.secondary.withAlpha(51),
                      child: Icon(Icons.chair, size: 40, color: colorScheme.onSurfaceVariant.withAlpha(128)),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatPrice(price),
                      style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.primary, fontSize: 15),
                    ),
                    _QuantitySelector(
                      quantity: quantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.textRating),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                    Expanded(
                      child: Text(
                        " • $brand",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    furnitureType.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCircBtn(
          icon: Icons.remove,
          onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          enabled: quantity > 1,
          colorScheme: colorScheme,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 30),
          alignment: Alignment.center,
          child: Text(
            quantity.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        _buildCircBtn(
          icon: Icons.add,
          onTap: () => onChanged(quantity + 1),
          enabled: true,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildCircBtn({
    required IconData icon,
    required VoidCallback? onTap,
    required bool enabled,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? colorScheme.primary.withAlpha(20) : colorScheme.outline.withAlpha(20),
          border: Border.all(color: enabled ? colorScheme.primary.withAlpha(51) : colorScheme.outline.withAlpha(51)),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? colorScheme.primary : colorScheme.outline,
        ),
      ),
    );
  }
}
