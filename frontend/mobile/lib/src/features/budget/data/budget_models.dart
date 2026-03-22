class BudgetRequest {
  BudgetRequest({
    required this.totalBudget,
    required this.requiredFurnitureTypes,
    required this.style,
    required this.colors,
    this.optionalFurnitureTypes = const [],
  });

  final int totalBudget;
  final List<String> requiredFurnitureTypes;
  final List<String> optionalFurnitureTypes;
  final String style;
  final List<String> colors;

  Map<String, dynamic> toJson() => {
        "totalBudget": totalBudget,
        "requiredFurnitureTypes": requiredFurnitureTypes,
        "optionalFurnitureTypes": optionalFurnitureTypes,
        "preferences": {
          "style": style,
          "colors": colors,
        },
      };
}

class BundleVariant {
  BundleVariant({
    required this.totalCost,
    required this.remaining,
    required this.requiredBundle,
    required this.optionalBundle,
    required this.explanations,
  });

  final num totalCost;
  final num remaining;
  final List<dynamic> requiredBundle;
  final List<dynamic> optionalBundle;
  final List<dynamic> explanations;

  factory BundleVariant.fromJson(Map<String, dynamic> json) => BundleVariant(
        totalCost: json["totalCost"] ?? 0,
        remaining: json["remaining"] ?? 0,
        requiredBundle: (json["requiredBundle"] ?? const []) as List<dynamic>,
        optionalBundle: (json["optionalBundle"] ?? const []) as List<dynamic>,
        explanations: (json["explanations"] ?? const []) as List<dynamic>,
      );
}

class BudgetResponse {
  BudgetResponse({
    required this.ok,
    required this.totalBudget,
    required this.bundles,
    required this.reason,
  });

  final bool ok;
  final int totalBudget;
  final List<BundleVariant> bundles;
  final String? reason;

  factory BudgetResponse.fromJson(Map<String, dynamic> json) => BudgetResponse(
        ok: json["ok"] == true,
        totalBudget: (json["totalBudget"] ?? 0) as int,
        bundles: (json["bundles"] as List<dynamic>? ?? [])
            .map((x) => BundleVariant.fromJson(x as Map<String, dynamic>))
            .toList(),
        reason: json["reason"] as String?,
      );
}
