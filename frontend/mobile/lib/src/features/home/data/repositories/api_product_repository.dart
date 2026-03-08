import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api_config.dart';
import '../models/furniture_model.dart';
import 'furniture_repository.dart';

/// Repository that fetches products from the NestJS backend API
/// instead of returning hardcoded mock data.
class ApiProductRepository implements IFurnitureRepository {
  final http.Client _client;

  ApiProductRepository({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<Furniture>> fetchFurniture() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/products');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products (status ${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body);

    // The backend wraps responses with a ResponseTransformInterceptor.
    // If the response has a 'data' key, use that; otherwise treat the
    // body itself as the list.
    final List<dynamic> items =
        (body is Map && body.containsKey('data')) ? body['data'] : body;

    return items
        .map((json) => Furniture.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
