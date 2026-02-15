import 'package:flutter/material.dart';

class BudgetResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const BudgetResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool ok = result['ok'] == true;

    final List<dynamic> requiredBundle = (result['requiredBundle'] as List?) ?? [];
    final List<dynamic> optionalBundle = (result['optionalBundle'] as List?) ?? [];

    final totalBudget = result['totalBudget'];
    final totalCost = result['totalCost'];
    final remaining = result['remaining'];
    final reason = result['reason'];

    final items = [...requiredBundle, ...optionalBundle];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Result"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                ok: ok,
                totalBudget: totalBudget,
                totalCost: totalCost,
                remaining: remaining,
                reason: reason,
              ),
              const SizedBox(height: 16),

              const Text(
                "Bundle Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          ok ? "No items returned." : (reason ?? "No bundle could be generated."),
                          style: const TextStyle(fontSize: 16),
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
  final dynamic totalBudget;
  final dynamic totalCost;
  final dynamic remaining;
  final dynamic reason;

  const _SummaryCard({
    required this.ok,
    required this.totalBudget,
    required this.totalCost,
    required this.remaining,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFE9F7EF) : const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ok ? Colors.green.shade200 : Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ok ? "Bundle generated ✅" : "Couldn’t generate bundle ❌",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Total budget: LKR $totalBudget"),
          Text("Total cost: LKR $totalCost"),
          Text("Remaining: LKR $remaining"),
          if (!ok && reason != null) ...[
            const SizedBox(height: 8),
            Text("Reason: $reason", style: const TextStyle(fontWeight: FontWeight.w600)),
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
    final name = product['name'] ?? "Unknown";
    final price = product['price'] ?? "-";
    final category = product['category'] ?? "-";
    final rating = product['rating'] ?? "-";
    final brand = product['brand'] ?? "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E2CF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.chair_alt, size: 34),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("LKR $price", style: const TextStyle(fontWeight: FontWeight.w600)),
                Text("Brand: $brand", style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text("$rating • $category"),
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
