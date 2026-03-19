import './models/furniture_model.dart';

/// Base state for AI search
sealed class AiSearchState {
  const AiSearchState();
}

/// Initial state - no search performed yet
class AiSearchInitial extends AiSearchState {
  const AiSearchInitial();
}

/// Loading state - search in progress
class AiSearchLoading extends AiSearchState {
  final String query;
  
  const AiSearchLoading(this.query);
}

/// Success state - results returned
class AiSearchSuccess extends AiSearchState {
  final String query;
  final List<Furniture> results;
  final String semanticMode;
  
  const AiSearchSuccess({
    required this.query,
    required this.results,
    required this.semanticMode,
  });
}

/// Empty state - search returned no results
class AiSearchEmpty extends AiSearchState {
  final String query;
  
  const AiSearchEmpty(this.query);
}

/// Error state - search failed
class AiSearchError extends AiSearchState {
  final String message;
  final String? query;
  
  const AiSearchError({
    required this.message,
    this.query,
  });
}
