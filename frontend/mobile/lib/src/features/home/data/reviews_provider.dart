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

// ─── Initial Review Data (scopable per product ID) ─────────────────────────
// Providing custom, believable reviews tailored to specific products.
// 6 specific products deliberately listed with empty arrays.
final Map<String, List<Review>> _initialReviews = {
  // ── 6 Products with NO reviews ──
  '1b': [],
  '1c': [],
  '2b': [],
  '2c': [],
  '2d': [],
  '2e': [],

  // ── Custom tailored reviews for the rest ──
  '1': [
    const Review(
      reviewerName: 'Alice M.',
      text:
          'Extremely comfortable sofa. The fabric feels premium and it fits perfectly into our modern living room setup. Highly recommended!',
      rating: 5,
    ),
    const Review(
      reviewerName: 'John Anderson',
      text:
          'Good value for money. The seating is plush and deep. Assembly took a bit of effort but the final result is wonderful.',
      rating: 4,
    ),
  ],
  '1d': [
    const Review(
      reviewerName: 'Sarah K.',
      text:
          'Massive and so cozy! Perfect for family movie nights. The L-shape design utilizes our corner space brilliantly.',
      rating: 5,
    ),
  ],
  '2': [
    const Review(
      reviewerName: 'David W.',
      text:
          'Very sturdy frame and the hardwood legs look great. The seating is a bit firm initially but gets much softer after a couple of weeks of use.',
      rating: 4,
    ),
  ],
  '3': [
    const Review(
      reviewerName: 'Emma R.',
      text:
          'Ideal for my small apartment. It’s compact, lightweight, but doesn’t feel cramped when sitting. The microfibre is easy to clean too.',
      rating: 5,
    ),
  ],
  '4': [
    const Review(
      reviewerName: 'Stephan Russell',
      text:
          'This chair adds such a warm, inviting vibe to my reading nook. The classic detailing on the edges makes it look way more expensive than it is.',
      rating: 5,
    ),
  ],
  '5': [
    const Review(
      reviewerName: 'Michael H.',
      text:
          'Sleek and minimalist dining table. The matte finish is gorgeous, though you do have to wipe it down frequently to keep it spotless.',
      rating: 4,
    ),
    const Review(
      reviewerName: 'Chloe B.',
      text:
          'Beautiful modern design that completely transformed our dining room. Fits 4 to 6 chairs comfortably without feeling cramped.',
      rating: 5,
    ),
  ],
  '6': [
    const Review(
      reviewerName: 'Liam T.',
      text:
          'The adjustable arc is super handy for reading on the couch. It emits a really great warm, flicker-free light. Worth every penny.',
      rating: 5,
    ),
  ],
};

// ─── State: Map<productId, List<Review>> ──────────────────────────────────────
class ReviewsNotifier extends StateNotifier<Map<String, List<Review>>> {
  ReviewsNotifier() : super({});

  /// Seeds the review list for [productId] using the tailored initial data.
  /// If no initial data exists for this product, it defaults to an empty list.
  void ensureSeeded(String productId) {
    if (!state.containsKey(productId)) {
      state = {
        ...state,
        productId: _initialReviews[productId] ?? [],
      };
    }
  }

  /// Adds a new review to the specified product only.
  void addReview(String productId, Review review) {
    // If the slot doesn't exist yet, seed first then append.
    final current = state[productId] ?? _initialReviews[productId] ?? [];
    state = {
      ...state,
      productId: [...current, review],
    };
  }

  /// Helper to let the UI access initial data safely on the very first frame
  List<Review> getInitialReviews(String productId) {
    return _initialReviews[productId] ?? [];
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, Map<String, List<Review>>>(
  (ref) => ReviewsNotifier(),
);
