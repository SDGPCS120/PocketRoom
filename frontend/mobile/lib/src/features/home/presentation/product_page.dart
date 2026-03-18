import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
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
  int _selectedColorIndex = 0;
  int _selectedMaterialIndex = 0;
  int _selectedSizeIndex = 0;
  bool _descExpanded = false;

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

  // Parse dimensions string into readable label-value pairs
  List<_SpecRow> _parseDimensions(String raw) {
    if (raw.isEmpty || raw == 'N/A') {
      return [_SpecRow('Dimensions', 'Not specified')];
    }
    // Try to extract numeric values from patterns like {width: 25, height: 75, depth: 25}
    final patterns = {
      'Height': RegExp(r'height[:\s]*(\d+)', caseSensitive: false),
      'Width': RegExp(r'width[:\s]*(\d+)', caseSensitive: false),
      'Depth': RegExp(r'depth[:\s]*(\d+)', caseSensitive: false),
      'Length': RegExp(r'length[:\s]*(\d+)', caseSensitive: false),
    };
    final results = <_SpecRow>[];
    for (final entry in patterns.entries) {
      final match = entry.value.firstMatch(raw);
      if (match != null) {
        results.add(_SpecRow(entry.key, '${match.group(1)} cm'));
      }
    }
    if (results.isEmpty) {
      // Fallback: show the raw string cleaned up (no JSON chars)
      final clean = raw.replaceAll(RegExp(r'[{}]'), '').trim();
      return [_SpecRow('Size', clean.isEmpty ? 'Not specified' : clean)];
    }
    return results;
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

  List<String> _getDynamicImages(Furniture f) {
    if (f.images.isEmpty) {
      return const [
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&q=80&w=800'
      ];
    }
    
    // Optional: Rotate images based on color index if variants are encoded in f.images
    final startIndex = _selectedColorIndex % f.images.length;
    
    final items = <String>[];
    for (var i = 0; i < f.images.length; i++) {
        final imgIndex = (startIndex + i) % f.images.length;
        items.add(f.images[imgIndex]);
    }
    return items;
  }

  void _openZoom(BuildContext context, String imageUrl, int index) {
    final heroTag = '${imageUrl}_$index';
    
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (context, _, __) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Hero(
                        tag: heroTag,
                        child: Image.network(imageUrl, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.furniture;
    final hasOldPrice = f.oldPrice != null && !f.oldPrice!.isNaN;
    final hasDescription = f.description.isNotEmpty;
    final hasColors = f.colorOptions.isNotEmpty;

    // Watch the reviews map; fall back to the seed list without mutating state.
    final reviews = ref.watch(reviewsProvider)[f.id] ??
        ref.read(reviewsProvider.notifier).getInitialReviews(f.id);

    final currentImages = _getDynamicImages(f);
    final topGalleryHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Scrollable body ─────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Immersive Image Gallery ────────────────────────────────
                SizedBox(
                  height: topGalleryHeight,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: currentImages.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (context, index) {
                          final imageUrl = currentImages[index];
                          final heroTag = '${imageUrl}_$index';
                          return GestureDetector(
                            onTap: () => _openZoom(context, imageUrl, index),
                            child: Hero(
                              tag: heroTag,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.secondary,
                                  child: const Icon(Icons.image_not_supported,
                                      size: 80, color: AppColors.textSecondary),
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
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Gradient Overlay for bottom readability
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: topGalleryHeight * 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Dots Indicator
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(currentImages.length, (idx) {
                            final isSelected = _currentPage == idx;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 6,
                              width: isSelected ? 20 : 6,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── White details card ────────────────────────────────
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Title & Trust Info ────────────────────────
                          Text(
                            f.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'by ${f.brand}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.primary, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                f.rating.isNaN ? 'N/A' : f.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '· ${reviews.length} reviews',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (f.stockStatus == false ? Colors.red : Colors.green).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  f.stockStatus == false ? 'Out of Stock' : 'In Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: f.stockStatus == false ? Colors.red : Colors.green[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '· Delivery in 3–5 days',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Price Section ───────────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatPrice(f.price),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  height: 1.0,
                                ),
                              ),
                              if (hasOldPrice && f.oldPrice! > f.price && f.oldPrice! > 0) ...[
                                const SizedBox(width: 12),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    _formatPrice(f.oldPrice!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Save ${((1 - f.price / f.oldPrice!) * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'or 3x ${_formatPrice(f.price / 3)} with Interest Free Plans',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

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
                            const SizedBox(height: 24),
                          ],

                          // ── Variant Selectors ────────────────────────
                          Builder(builder: (context) {
                            // Static size labels – always clean and readable
                            const sizeLabels = ['Small', 'Medium', 'Large'];

                            // Material options
                            final materials = f.material.isNotEmpty
                                ? [f.material]
                                : ['Fabric', 'Leather', 'Velvet'];

                            // Color name lookup helper
                            final colorNames = ['Black', 'Charcoal', 'White', 'Cream', 'Brown', 'Slate'];
                            final cName = hasColors
                                ? colorNames[_selectedColorIndex % colorNames.length]
                                : 'Default';
                            final mName = materials[_selectedMaterialIndex % materials.length];
                            final sName = sizeLabels[_selectedSizeIndex % sizeLabels.length];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Selected summary
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Selected:  ',
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      TextSpan(
                                        text: '$cName  •  $mName  •  $sName',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // ── Color ──────────────────────────────
                                const Text('Color',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (hasColors)
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: List.generate(f.colorOptions.length, (idx) {
                                      final c = f.colorOptions[idx];
                                      final isSelected = _selectedColorIndex == idx;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedColorIndex = idx;
                                            _currentPage = 0;
                                          });
                                          if (_pageController.hasClients) {
                                            _pageController.jumpToPage(0);
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: isSelected ? 36 : 30,
                                          height: isSelected ? 36 : 30,
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? AppColors.primary : Colors.grey[300]!,
                                              width: isSelected ? 2.5 : 1,
                                            ),
                                            boxShadow: isSelected ? [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.25),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ] : null,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: c,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  )
                                else
                                  Wrap(
                                    spacing: 12,
                                    children: List.generate(
                                      colorNames.take(4).length,
                                      (idx) {
                                        const fallbackColors = [
                                          Colors.black87,
                                          Color(0xFF607D8B),
                                          Colors.white,
                                          Color(0xFFD4B896),
                                        ];
                                        final isSelected = _selectedColorIndex == idx;
                                        return GestureDetector(
                                          onTap: () => setState(() => _selectedColorIndex = idx),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: isSelected ? 36 : 30,
                                            height: isSelected ? 36 : 30,
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                                                width: isSelected ? 2.5 : 1,
                                              ),
                                              boxShadow: isSelected ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withValues(alpha: 0.25),
                                                  blurRadius: 6,
                                                ),
                                              ] : null,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: fallbackColors[idx],
                                                shape: BoxShape.circle,
                                                border: fallbackColors[idx] == Colors.white
                                                    ? Border.all(color: Colors.grey[300]!)
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                const SizedBox(height: 22),
                                Divider(color: Colors.grey[200], height: 1),
                                const SizedBox(height: 20),

                                // ── Material / Finish ───────────────────
                                const Text('Material',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(materials.length, (idx) {
                                      final m = materials[idx];
                                      final isSelected = _selectedMaterialIndex == idx;
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedMaterialIndex = idx),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(22),
                                            border: Border.all(
                                              color: isSelected ? AppColors.primary : Colors.grey[300]!,
                                              width: isSelected ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            m,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                              color: isSelected ? Colors.white : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                const SizedBox(height: 22),
                                Divider(color: Colors.grey[200], height: 1),
                                const SizedBox(height: 20),

                                // ── Size ────────────────────────────────
                                const Text('Size',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(sizeLabels.length, (idx) {
                                    final s = sizeLabels[idx];
                                    final isSelected = _selectedSizeIndex == idx;
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedSizeIndex = idx),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : Colors.grey[300]!,
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Text(
                                          s,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            color: isSelected ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 28),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 20),

                          // ── Quantity Selector ──────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quantity',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Only 3 left in stock',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (_quantity > 1) {
                                          setState(() => _quantity--);
                                        }
                                      },
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
                                      child: const SizedBox(
                                        width: 42,
                                        child: Center(child: Icon(Icons.remove_rounded, size: 18, color: AppColors.textPrimary)),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Colors.grey[300],
                                    ),
                                    SizedBox(
                                      width: 36,
                                      child: Center(
                                        child: Text(
                                          '$_quantity',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Colors.grey[300],
                                    ),
                                    InkWell(
                                      onTap: () => setState(() => _quantity++),
                                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(22)),
                                      child: const SizedBox(
                                        width: 42,
                                        child: Center(child: Icon(Icons.add_rounded, size: 18, color: AppColors.textPrimary)),
                                      ),
                                    ),
                                  ],
                                ),
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
                              child: const Text('Add to Cart'),
                            ),
                          ),
                          // ── Bottom spacer so content clears sticky bar
                          const SizedBox(height: 32),

                          // ═══════════════════════════════════════════════
                          // 1. DIMENSIONS & SPECIFICATIONS
                          // ═══════════════════════════════════════════════
                          _SectionHeader(title: 'Specifications'),
                          const SizedBox(height: 16),

                          // Dimensions card
                          _SpecCard(
                            icon: Icons.straighten_rounded,
                            label: 'Dimensions',
                            rows: _parseDimensions(f.dimensions),
                            trailingWidget: Container(
                              width: 86,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.chair_alt_outlined, size: 44, color: Colors.grey[300]),
                                  Positioned(
                                    left: 12,
                                    top: 14,
                                    bottom: 14,
                                    child: Container(width: 1.5, color: AppColors.primary.withValues(alpha: 0.4)),
                                  ),
                                  const Positioned(
                                    left: 16,
                                    top: 16,
                                    child: Text('H', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                  Positioned(
                                    bottom: 14,
                                    left: 12,
                                    right: 12,
                                    child: Container(height: 1.5, color: AppColors.primary.withValues(alpha: 0.4)),
                                  ),
                                  const Positioned(
                                    bottom: 18,
                                    right: 14,
                                    child: Text('W', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Materials card
                          _SpecCard(
                            icon: Icons.texture_rounded,
                            label: 'Materials',
                            rows: [
                              if (f.material.isNotEmpty)
                                _SpecRow('Material', f.material)
                              else
                                _SpecRow('Frame', 'Steel'),
                              _SpecRow('Seat', 'High-Density Foam'),
                              _SpecRow('Finish', 'Matte Powder Coat'),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Other card
                          _SpecCard(
                            icon: Icons.info_outline_rounded,
                            label: 'General',
                            rows: [
                              _SpecRow('Category', f.furnitureType),
                              _SpecRow('Brand', f.brand),
                              _SpecRow('Weight Capacity', '120 kg'),
                              _SpecRow('Assembly', 'Required (30 min)'),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Divider(color: Colors.grey[200]),
                          const SizedBox(height: 28),

                          // ═══════════════════════════════════════════════
                          // 2. DESCRIPTION (COLLAPSIBLE)
                          // ═══════════════════════════════════════════════
                          if (f.description.isNotEmpty) ...[
                            _SectionHeader(title: 'Description'),
                            const SizedBox(height: 12),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: _descExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: Text(
                                f.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.65,
                                ),
                              ),
                              secondChild: Text(
                                f.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.65,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => _descExpanded = !_descExpanded),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _descExpanded ? 'Show less' : 'Read more',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  AnimatedRotation(
                                    duration: const Duration(milliseconds: 250),
                                    turns: _descExpanded ? 0.5 : 0,
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Divider(color: Colors.grey[200]),
                            const SizedBox(height: 28),
                          ],

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

          // ─── Top floating glass buttons ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      _GlassButton(
                        icon: Icons.share_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _GlassButton(
                        icon: Icons.favorite_border_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Sticky Bottom Action Bar ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          // ── Add to Cart (secondary) ────────────────────
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  for (var i = 0; i < _quantity; i++) {
                                    ref.read(cartProvider.notifier).addItem(f);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${f.name} ×$_quantity added to cart'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: AppColors.primary,
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        color: AppColors.primary,
                                        size: 17,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // ── View in AR (primary, 65%) ──────────────────
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {},
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF8C42),
                                        AppColors.primary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.38),
                                        blurRadius: 14,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.view_in_ar_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'View in AR',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              height: 1.1,
                                            ),
                                          ),
                                          Text(
                                            'Try in your room',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
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

// ─── Glass Floating Button ────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withValues(alpha: 0.4),
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 22, color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}



class _SpecRow {
  final String label;
  final String value;
  const _SpecRow(this.label, this.value);
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<_SpecRow> rows;
  final Widget? trailingWidget;
  const _SpecCard({required this.icon, required this.label, required this.rows, this.trailingWidget});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200], height: 1),
          // Rows and Trailing Diagram
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: rows.asMap().entries.map((entry) {
                      final isLast = entry.key == rows.length - 1;
                      final row = entry.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    row.label,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    row.value,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) Divider(color: Colors.grey[200], height: 1, indent: 14, endIndent: 14),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                if (trailingWidget != null) ...[
                  Container(width: 1, color: Colors.grey[200]),
                  trailingWidget!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
