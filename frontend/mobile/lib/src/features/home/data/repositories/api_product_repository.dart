import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api_config.dart';
import '../models/furniture_model.dart';
import '../models/vendor_model.dart';
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

  @override
  Future<List<Vendor>> fetchVendors() async {
    final products = await fetchFurniture();
    final brands = products.map((p) => p.brand).toSet();
    return brands.map((brand) => Vendor(
      id: brand.toLowerCase().replaceAll(' ', '_'),
      name: brand,
      description: 'Exclusive furniture collection from $brand.',
      rating: 4.5,
    )).toList();
  }

  @override
  Future<List<Furniture>> fetchFurnitureByVendor(String vendorName) async {
    final products = await fetchFurniture();
    return products.where((p) => p.brand.toLowerCase() == vendorName.toLowerCase()).toList();
  }

  @override
  Future<Vendor?> fetchVendorByName(String name) async {
    final vendors = await fetchVendors();
    try {
      return vendors.firstWhere((v) => v.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}
