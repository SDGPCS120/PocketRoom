import '../../features/home/data/models/ai_search_request.dart';
import '../../features/home/data/models/ai_search_response.dart';
import 'api_client.dart';

/// Service for AI search functionality
class AiSearchService {
  final ApiClient _apiClient;

  AiSearchService(this._apiClient);

  /// Perform AI search with the given query
  /// 
  /// [query] - The search query string
  /// [topK] - Maximum number of results to return (default: 10)
  /// 
  /// Returns [AiSearchResponse] with scored and ranked results
  /// Throws [ApiException] on network or server errors
  Future<AiSearchResponse> searchAi(
    String query, {
    int topK = 10,
  }) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('Query cannot be empty');
    }

    final request = AiSearchRequest(
      query: query.trim(),
      topK: topK,
    );

    final response = await _apiClient.post(
      '/search',
      data: request.toJson(),
    );

    return AiSearchResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Check backend health status
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
