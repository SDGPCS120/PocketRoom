import '../../home/data/models/furniture_model.dart';

sealed class AiSearchState {
  const AiSearchState();
}

class AiSearchInitial extends AiSearchState {
  const AiSearchInitial();
}

class AiSearchLoading extends AiSearchState {
  const AiSearchLoading();
}

class AiSearchSuccess extends AiSearchState {
  final List<Furniture> results;
  const AiSearchSuccess(this.results);
}

class AiSearchEmpty extends AiSearchState {
  final String query;
  const AiSearchEmpty(this.query);
}

class AiSearchError extends AiSearchState {
  final String message;
  final String? query;
  const AiSearchError(this.message, {this.query});
}
