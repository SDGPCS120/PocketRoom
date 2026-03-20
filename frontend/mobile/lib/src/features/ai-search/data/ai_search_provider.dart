import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/models/furniture_model.dart';
import '../../home/data/repositories/furniture_repository.dart';
import '../../home/data/providers.dart';
import '../../../core/api_config.dart';
import 'ai_search_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiSearchNotifier extends StateNotifier<AiSearchState> {
  final IFurnitureRepository _repository;
  final String _baseUrl;

  AiSearchNotifier(this._repository, this._baseUrl) : super(const AiSearchInitial());

  Future<void> searchAi(String query) async {
    if (query.isEmpty) return;

    state = const AiSearchLoading();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic jsonResponse = jsonDecode(response.body);
        List<dynamic> rawResults = [];

        if (jsonResponse is List) {
          rawResults = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse.containsKey('results')) {
          rawResults = jsonResponse['results'];
        } else if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          rawResults = jsonResponse['data'];
        }
        
        final results = rawResults.map((item) {
          if (item is Map && item.containsKey('product')) {
            return Furniture.fromJson(item['product'] as Map<String, dynamic>);
          }
          return Furniture.fromJson(item as Map<String, dynamic>);
        }).toList();

        if (results.isEmpty) {
          state = AiSearchEmpty(query);
        } else {
          state = AiSearchSuccess(results);
        }
      } else {
        state = AiSearchError('Failed to fetch AI results: ${response.statusCode}', query: query);
      }
    } catch (e) {
      state = AiSearchError('Connection error: $e', query: query);
    }
  }

  void clearResults() {
    state = const AiSearchInitial();
  }

  void retry() {
    final currentState = state;
    if (currentState is AiSearchError && currentState.query != null) {
      searchAi(currentState.query!);
    }
  }
}

final aiSearchStateProvider = StateNotifierProvider<AiSearchNotifier, AiSearchState>((ref) {
  final repository = ref.watch(furnitureRepositoryProvider);
  // Using the centralized base URL
  final baseUrl = ApiConfig.baseUrl;
  return AiSearchNotifier(repository, baseUrl);
});
