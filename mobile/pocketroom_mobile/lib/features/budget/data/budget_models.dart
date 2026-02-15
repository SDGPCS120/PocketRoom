class BudgetRequest {
  BudgetRequest({
    required this.totalBudget,
    required this.requiredCategories,
    required this.style,
    required this.colors,
  });

  final int totalBudget;
  final List<String> requiredCategories;
  final String style;
  final List<String> colors;

  Map<String, dynamic> toJson() => {
        "totalBudget": totalBudget,
        "requiredCategories": requiredCategories,
        "style": style,
        "colors": colors,
      };
}

class BudgetResponse {
  BudgetResponse({
    required this.ok,
    required this.totalBudget,
    required this.totalCost,
    required this.remaining,
    required this.requiredBundle,
    required this.optionalBundle,
    required this.explanations,
    required this.reason,
  });

  final bool ok;
  final int totalBudget;
  final num totalCost;
  final num remaining;
  final List<dynamic> requiredBundle;
  final List<dynamic> optionalBundle;
  final List<dynamic> explanations;
  final String? reason;

  factory BudgetResponse.fromJson(Map<String, dynamic> json) => BudgetResponse(
        ok: json["ok"] == true,
        totalBudget: (json["totalBudget"] ?? 0) as int,
        totalCost: json["totalCost"] ?? 0,
        remaining: json["remaining"] ?? 0,
        requiredBundle: (json["requiredBundle"] ?? const []) as List<dynamic>,
        optionalBundle: (json["optionalBundle"] ?? const []) as List<dynamic>,
        explanations: (json["explanations"] ?? const []) as List<dynamic>,
        reason: json["reason"] as String?,
      );
}
