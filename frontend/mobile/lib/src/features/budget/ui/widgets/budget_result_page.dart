import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
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
        title: Text("Budget Result", style: TextStyle(color: colorScheme.onSurface)),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex = (_currentIndex + 1) % bundles.length;
                        });
                      },
                      icon: const Icon(Icons.skip_next),
                      label: const Text("Next Bundle"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
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
              const SizedBox(height: 16),

              Text(
                "Bundle Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
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

                          // backend might return either {category,id,name,price,...}
                          // or {product:{...}}
                          final product = (item['product'] is Map) ? item['product'] : item;

                          return _ProductCard(product: Map<String, dynamic>.from(product));
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
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = ok ? colorScheme.primaryContainer : colorScheme.errorContainer;
    final textColor = ok ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer;
    final borderColor = ok ? colorScheme.primary.withValues(alpha: 0.3) : colorScheme.error.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ok ? "Bundle generated ✅" : "Couldn’t generate bundle ❌",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          Text("Total budget: ${totalBudget.toLKR()}", style: TextStyle(color: textColor)),
          Text("Total cost: ${totalCost.toLKR()}", style: TextStyle(color: textColor)),
          Text("Remaining: ${remaining.toLKR()}", style: TextStyle(color: textColor)),
          if (!ok && reason != null) ...[
            const SizedBox(height: 8),
            Text("Reason: $reason", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
          ],
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = product['name'] ?? "Unknown";
    final price = product['price'] as num? ?? 0;
    final category = product['category'] ?? "-";
    final rating = product['rating'] ?? "-";
    final brand = product['brand'] ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.chair_alt, size: 34, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  price.toLKR(), 
                  style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.primary),
                ),
                Text(
                  "Brand: $brand", 
                  style: TextStyle(color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      "$rating • $category",
                      style: TextStyle(color: colorScheme.onSecondaryContainer),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
