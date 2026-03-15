import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single product review.
class Review {
  final String reviewerName;
  final String text;
  final int rating; // 1–5 stars

  const Review({
    required this.reviewerName,
    required this.text,
    this.rating = 5,
  });
}

// ─── Default seed review — exported so product_page can use it as a fallback ──
const defaultSeedReview = Review(
  reviewerName: 'Stephan Russell',
  text:
      'This chair adds such a warm vibe to my living room. The detailing on the edges makes it look way more expensive.',
  rating: 5,
);

// ─── State: Map<productId, List<Review>> ──────────────────────────────────────
class ReviewsNotifier extends StateNotifier<Map<String, List<Review>>> {
  ReviewsNotifier() : super({});

  /// Seeds the review list for [productId] with one default review the first
  /// time it is called. Safe to call from initState (never call from build).
  void ensureSeeded(String productId) {
    if (!state.containsKey(productId)) {
      state = {
        ...state,
        productId: [defaultSeedReview],
      };
    }
  }

  /// Adds a new review to the specified product only.
  void addReview(String productId, Review review) {
    // If the slot doesn't exist yet, seed first then append.
    final current = state[productId] ?? [defaultSeedReview];
    state = {
      ...state,
      productId: [...current, review],
    };
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, Map<String, List<Review>>>(
  (ref) => ReviewsNotifier(),
);
