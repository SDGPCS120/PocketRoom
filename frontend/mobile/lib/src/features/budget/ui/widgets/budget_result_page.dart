import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../home/data/models/furniture_model.dart';

class BudgetResultPage extends StatefulWidget {
  final Map<String, dynamic> result;

  const BudgetResultPage({super.key, required this.result});

  @override
  State<BudgetResultPage> createState() => _BudgetResultPageState();
}

class _BudgetResultPageState extends State<BudgetResultPage> {
  int _currentIndex = 0;

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

    final totalCost = currentBundle?['totalCost'] as num? ?? 0;
    final remaining = currentBundle?['remaining'] as num? ?? 0;

    final List<dynamic> requiredBundle = (currentBundle?['requiredBundle'] as List?) ?? [];
    final List<dynamic> optionalBundle = (currentBundle?['optionalBundle'] as List?) ?? [];

    final items = [...requiredBundle, ...optionalBundle];

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
                totalCost: totalCost,
                remaining: remaining,
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
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index] as Map<String, dynamic>;
                          return _ProductItem(product: item);
                        },
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

  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // backend might return either {category,id,name,price,...}
    // or {product:{...}}
    final itemData = (product['product'] is Map) 
        ? Map<String, dynamic>.from(product['product']) 
        : product;

    // Use the actual Furniture model to parse images/brand consistently with Home page
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
    
    if (kDebugMode) {
      debugPrint('[BudgetResult] Item: $name, Brand: $brand, URL: $imageUrl');
    }

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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.secondary.withAlpha(51),
                          child: Icon(Icons.chair, size: 40, color: colorScheme.onSurfaceVariant.withAlpha(128)),
                        );
                      },
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
                Text(
                  formatPrice(price),
                  style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.primary, fontSize: 15),
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
