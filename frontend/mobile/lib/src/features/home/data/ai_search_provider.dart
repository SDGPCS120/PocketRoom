import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/ai_search_service.dart';
import './ai_search_state.dart';

/// Provider for API client
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider for AI search service
final aiSearchServiceProvider = Provider<AiSearchService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiSearchService(apiClient);
});

/// State notifier for managing AI search state
class AiSearchNotifier extends StateNotifier<AiSearchState> {
  final AiSearchService _searchService;

  AiSearchNotifier(this._searchService) : super(const AiSearchInitial());

  /// Perform AI search with the given query
  Future<void> searchAi(String query) async {
    if (query.trim().isEmpty) {
      state = const AiSearchError(message: 'Please enter a search query');
      return;
    }

    // Set loading state
    state = AiSearchLoading(query);

    try {
      // Call the AI search service
      final response = await _searchService.searchAi(query);

      // Convert results to Furniture models
      final furnitureResults = response.results
          .map((item) => item.toFurniture())
          .toList();

      // Update state based on results
      if (furnitureResults.isEmpty) {
        state = AiSearchEmpty(query);
      } else {
        state = AiSearchSuccess(
          query: query,
          results: furnitureResults,
          semanticMode: response.semanticMode,
        );
      }
    } on ApiException catch (e) {
      state = AiSearchError(
        message: e.message,
        query: query,
      );
    } catch (e) {
      state = AiSearchError(
        message: 'An unexpected error occurred: ${e.toString()}',
        query: query,
      );
    }
  }

  /// Clear search results and return to initial state
  void clearResults() {
    state = const AiSearchInitial();
  }

  /// Retry the last search (useful for error recovery)
  Future<void> retry() async {
    final currentState = state;
    if (currentState is AiSearchError && currentState.query != null) {
      await searchAi(currentState.query!);
    }
  }
}

/// Provider for AI search state
final aiSearchStateProvider = StateNotifierProvider<AiSearchNotifier, AiSearchState>((ref) {
  final searchService = ref.watch(aiSearchServiceProvider);
  return AiSearchNotifier(searchService);
});
