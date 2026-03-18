import 'dart:convert';
import 'package:http/http.dart' as http;
import 'budget_models.dart';

class BudgetApi {
  BudgetApi({required this.baseUrl});
  final String baseUrl;

  Future<BudgetResponse> generateBundle(BudgetRequest req) async {
    final uri = Uri.parse('$baseUrl/budget/bundle');

    final res = await http.post(
      uri,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(req.toJson()),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('API ${res.statusCode}: ${res.body}');
    }

    return BudgetResponse.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
