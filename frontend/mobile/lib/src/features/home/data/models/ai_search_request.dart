/// Request model for AI search API
class AiSearchRequest {
  final String query;
  final int topK;

  const AiSearchRequest({
    required this.query,
    this.topK = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'top_k': topK,
    };
  }
}
