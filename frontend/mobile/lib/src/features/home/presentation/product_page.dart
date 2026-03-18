import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/get_started_page.dart';
import '../../../features/cart/data/cart_provider.dart';
import '../data/models/furniture_model.dart';
import '../data/reviews_provider.dart';

class ProductPage extends ConsumerStatefulWidget {
  final Furniture furniture;

  const ProductPage({super.key, required this.furniture});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  int _quantity = 1;

  // ── Add Review form state ─────────────────────────────────────────────────
  final _reviewFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  int _newRating = 5;

  @override
  void initState() {
    super.initState();
    // Seed this product's review list AFTER the first build completes.
    // Never call state-mutating methods directly inside build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(reviewsProvider.notifier).ensureSeeded(widget.furniture.id);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  // format price helper
  String _formatPrice(double price) {
    if (price.isNaN) return 'N/A';
    return "LKR ${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        )}";
  }

  void _submitReview() {
    if (!(_reviewFormKey.currentState?.validate() ?? false)) return;
    ref.read(reviewsProvider.notifier).addReview(
          widget.furniture.id,
          Review(
            reviewerName: _nameController.text.trim(),
            text: _reviewController.text.trim(),
            rating: _newRating,
          ),
        );
    _nameController.clear();
    _reviewController.clear();
    setState(() => _newRating = 5);
  }

  bool _redirectGuestToGetStarted() {
    final user = FirebaseAuth.instance.currentUser;
    final isSignedIn = user != null && !user.isAnonymous;
    if (isSignedIn) return false;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GetStartedPage()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.furniture;
    final hasImages = f.images.isNotEmpty;
    final hasOldPrice = f.oldPrice != null && !f.oldPrice!.isNaN;
    final hasDescription = f.description.isNotEmpty;
    final hasColors = f.colorOptions.isNotEmpty;

    // Watch the reviews map; fall back to the seed list without mutating state.
    final reviews = ref.watch(reviewsProvider)[f.id] ??
        ref.read(reviewsProvider.notifier).getInitialReviews(f.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Scrollable body ─────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image carousel ────────────────────────────────────
                SizedBox(
                  height: 340,
                  child: hasImages
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: f.images.length,
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          itemBuilder: (context, index) {
                            return Image.network(
                              f.images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.secondary,
                                child: const Icon(Icons.chair,
                                    size: 80,
                                    color: AppColors.textSecondary),
                              ),
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: AppColors.secondary,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.primary),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : Container(
                          color: AppColors.secondary,
                          child: const Icon(Icons.chair,
                              size: 80, color: AppColors.textSecondary),
                        ),
                ),

                // ── White details card ────────────────────────────────
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Dot indicators ──────────────────────────
                          if (hasImages && f.images.length > 1) ...[
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    List.generate(f.images.length, (i) {
                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    height: 7,
                                    width: _currentPage == i ? 22 : 7,
                                    decoration: BoxDecoration(
                                      color: _currentPage == i
                                          ? AppColors.primary
                                          : Colors.grey[300],
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Name + Brand + Rating ────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Brand: ${f.brand}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        color: AppColors.primary, size: 15),
                                    const SizedBox(width: 4),
                                    Text(
                                      f.rating.isNaN
                                          ? 'N/A'
                                          : f.rating.toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Price ────────────────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _formatPrice(f.price),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  height: 1.1,
                                ),
                              ),
                              if (hasOldPrice) ...[
                                const SizedBox(width: 10),
                                Text(
                                  _formatPrice(f.oldPrice!),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ── Description ──────────────────────────────
                          if (hasDescription) ...[
                            Text(
                              f.description,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // ── Colors + Quantity ────────────────────────
                          Row(
                            children: [
                              if (hasColors)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Available colors',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children:
                                            f.colorOptions.map((c) {
                                          return Container(
                                            width: 26,
                                            height: 26,
                                            decoration: BoxDecoration(
                                              color: c,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Quantity',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _QtyButton(
                                        icon: Icons.remove,
                                        onTap: () {
                                          if (_quantity > 1) {
                                            setState(() => _quantity--);
                                          }
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        child: Text(
                                          '$_quantity',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      _QtyButton(
                                        icon: Icons.add,
                                        onTap: () =>
                                            setState(() => _quantity++),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // ── Add to cart ──────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_redirectGuestToGetStarted()) {
                                  return;
                                }
                                for (var i = 0; i < _quantity; i++) {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addItem(f);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${f.name} ×$_quantity added to cart'),
                                    duration:
                                        const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Add to cart',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── View in AR ───────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                    color: AppColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'View in AR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ── Specifications ───────────────────────────
                          const Text(
                            'Specifications',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _SpecSection(
                              title: 'Dimensions',
                              bullets: [f.dimensions]),
                          _SpecSection(
                              title: 'Category',
                              bullets: [f.furnitureType]),
                          if (f.styleTags.isNotEmpty)
                            _SpecSection(
                                title: 'Style Tags', bullets: f.styleTags),
                          const SizedBox(height: 32),

                          // ── Reviews (dynamic, per-product) ───────────
                          Text(
                            'Reviews (${reviews.length})',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (reviews.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'No reviews yet. Be the first to review!',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            ...reviews.map(
                              (r) => _ReviewTile(
                                name: r.reviewerName,
                                review: r.text,
                                rating: r.rating,
                              ),
                            ),

                          const SizedBox(height: 24),

                          // ── Add Review form ──────────────────────────
                          _AddReviewForm(
                            formKey: _reviewFormKey,
                            nameController: _nameController,
                            reviewController: _reviewController,
                            rating: _newRating,
                            onRatingChanged: (v) =>
                                setState(() => _newRating = v),
                            onSubmit: _submitReview,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Floating back button ──────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: Colors.white.withValues(alpha: 0.85),
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back,
                        size: 22, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quantity +/- button ──────────────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

// ─── Specification section ────────────────────────────────────────────────────
class _SpecSection extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _SpecSection({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single review tile ────────────────────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final String name;
  final String review;
  final int rating;

  const _ReviewTile({
    required this.name,
    required this.review,
    this.rating = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: const Icon(Icons.person,
                size: 22, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        rating.clamp(0, 5),
                        (_) => const Icon(Icons.star,
                            color: AppColors.primary, size: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Review form card ─────────────────────────────────────────────────────
class _AddReviewForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController reviewController;
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const _AddReviewForm({
    required this.formKey,
    required this.nameController,
    required this.reviewController,
    required this.rating,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary, width: 1.2),
        boxShadow: AppColors.productCardShadow,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Add a Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Your name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),

            // Review text field
            TextFormField(
              controller: reviewController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration('Write your review…'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Review cannot be empty' : null,
            ),
            const SizedBox(height: 16),

            // Star rating selector
            const Text(
              'Your rating',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                return GestureDetector(
                  onTap: () => onRatingChanged(starIndex),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      starIndex <= rating ? Icons.star : Icons.star_border,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13.5,
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
