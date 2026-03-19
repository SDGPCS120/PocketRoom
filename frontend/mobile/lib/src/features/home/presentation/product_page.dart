import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
  bool _isCartPressed = false;
  bool _isARPressed = false;

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

  Widget _buildTrustBadge(IconData icon, String label, Color color) {
    return Container(
      height: 32, // Fixed height for all badges
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05), // Subtle tint
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
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
                              child: AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  double value = 1.0;
                                  if (_pageController.position.haveDimensions) {
                                    value = _pageController.page! - index;
                                    // Subtle zoom effect on current page
                                    value = (1 - (value.abs() * 0.08)).clamp(0.9, 1.0);
                                  }
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: (1 - value) * 20), // Subtle horizontal parallax
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.secondary,
                                          child: const Icon(Icons.chair_alt_rounded,
                                              size: 80, color: AppColors.textSecondary),
                                        ),
                                      ),
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
                        height: topGalleryHeight * 0.35,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Modern Progressive Indicator
                      Positioned(
                        bottom: 48,
                        left: 24,
                        right: 24,
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: (currentImages.length > 1) 
                                    ? (_currentPage + 1) / currentImages.length 
                                    : 1.0,
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 1.5, // Thinner for premium feel
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_currentPage + 1}/${currentImages.length}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Swipe Hint
                      if (_currentPage == 0 && currentImages.length > 1)
                        Positioned(
                          right: 24,
                          bottom: 80,
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: 0.8,
                            child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                               decoration: BoxDecoration(
                                 color: Colors.black.withValues(alpha: 0.25), // More subtle
                                 borderRadius: BorderRadius.circular(24),
                               ),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Text(
                                     'Swipe for more'.toUpperCase(),
                                     style: TextStyle(
                                         color: Colors.white.withValues(alpha: 0.8), 
                                         fontSize: 8, 
                                         fontWeight: FontWeight.w900,
                                         letterSpacing: 1.2,
                                     ),
                                   ),
                                   const SizedBox(width: 6),
                                   Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.8), size: 10),
                                 ],
                               ),
                             ),
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
                          // ── Title & Global Info ────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.name,
                                      style: TextStyle(
                                        fontSize: 34, // Larger
                                        fontWeight: FontWeight.w900, // Black
                                        color: AppColors.textPrimary,
                                        height: 1.0,
                                        letterSpacing: -1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      f.brand.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary.withValues(alpha: 0.5), // Lower opacity
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5, // Greater tracking
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      f.rating.isNaN ? '4.8' : f.rating.toString(),
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
                          
                          const SizedBox(height: 14), // Reduced spacer
                          
                          // Trust Signal Badges
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildTrustBadge(Icons.timer_rounded, 'ONLY 3 LEFT', Colors.red),
                                _buildTrustBadge(Icons.handyman_rounded, 'FREE INSTALL', Colors.blue),
                                _buildTrustBadge(Icons.verified_rounded, '1-YEAR WARRANTY', Colors.green),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Price Section ───────────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _formatPrice(f.price),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  height: 1.0,
                                  letterSpacing: -1,
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
                             'or 3 interest-free installments of ${_formatPrice(f.price / 3)}',
                             style: TextStyle(
                               fontSize: 12.5,
                               color: AppColors.textSecondary.withValues(alpha: 0.6),
                               fontWeight: FontWeight.w500,
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
                                    spacing: 8, // Reduced from 12
                                    runSpacing: 10,
                                    children: List.generate(f.colorOptions.length, (idx) {
                                      final c = f.colorOptions[idx];
                                      final isSelected = _selectedColorIndex == idx;
                                      return GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _selectedColorIndex = idx;
                                            _currentPage = 0;
                                          });
                                          if (_pageController.hasClients) {
                                            _pageController.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
                                          }
                                        },
                                        child: AnimatedScale(
                                          scale: isSelected ? 1.1 : 1.0,
                                          duration: const Duration(milliseconds: 200),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: 32,
                                            height: 32,
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? AppColors.primary : Colors.grey[200]!,
                                                width: isSelected ? 2 : 1,
                                              ),
                                              boxShadow: isSelected ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withValues(alpha: 0.15),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ] : null,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: c,
                                                shape: BoxShape.circle,
                                                border: c == Colors.white ? Border.all(color: Colors.grey[200]!) : null,
                                              ),
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
                                                width: 1,
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

                                const SizedBox(height: 18),
                                Divider(color: Colors.grey[100], height: 1, thickness: 0.5),
                                const SizedBox(height: 18),

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
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        margin: const EdgeInsets.only(right: 8),
                                        curve: Curves.easeOutCubic,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : Colors.grey[200]!,
                                            width: 1,
                                          ),
                                          boxShadow: isSelected ? [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.15),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ] : null,
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() => _selectedMaterialIndex = idx);
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              child: Text(
                                                m,
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                                ),
                                              ),
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
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOutCubic,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : Colors.grey[200]!,
                                          width: 1,
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.15),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ] : null,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => setState(() => _selectedSizeIndex = idx),
                                          borderRadius: BorderRadius.circular(12),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 24),
                          Divider(color: Colors.grey[100], height: 1, thickness: 0.5),
                          const SizedBox(height: 18),

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
                          const SizedBox(height: 40),

                          // ═══════════════════════════════════════════════
                          // 1. SPECIFICATIONS (ACCORDION)
                          // ═══════════════════════════════════════════════
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              collapsedIconColor: AppColors.textPrimary,
                              iconColor: AppColors.primary,
                              title: const Text(
                                'Specifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              children: [
                                const SizedBox(height: 12),
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
                          // Product Info card
                          _SpecCard(
                            icon: Icons.info_outline_rounded,
                            label: 'Product Details',
                            rows: [
                              _SpecRow('Category', f.furnitureType),
                              _SpecRow('Brand', f.brand),
                              _SpecRow('Weight Capacity', '120 kg'),
                              _SpecRow('Assembly', 'Required (30 min)'),
                            ],
                          ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[100], thickness: 1),
                          const SizedBox(height: 12),

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

                          // ═══════════════════════════════════════════════
                          // 2. DELIVERY & WARRANTY (ACCORDION)
                          // ═══════════════════════════════════════════════
                          Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              collapsedIconColor: AppColors.textPrimary,
                              iconColor: AppColors.primary,
                              title: const Text(
                                'Delivery & Warranty',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey[50]!),
                                  ),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 4),
                                      const _InfoRow(
                                        icon: Icons.local_shipping_outlined,
                                        title: 'Islandwide delivery',
                                        subtitle: 'Estimated time: 3–5 working days',
                                      ),
                                      Divider(color: Colors.grey[100], height: 1, indent: 56),
                                      const _InfoRow(
                                        icon: Icons.refresh_rounded,
                                        title: '7-day return policy',
                                        subtitle: 'Easy returns if unused and in original condition',
                                      ),
                                      Divider(color: Colors.grey[100], height: 1, indent: 56),
                                      const _InfoRow(
                                        icon: Icons.verified_user_outlined,
                                        title: '1-year warranty',
                                        subtitle: 'Covers manufacturing defects',
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[100], thickness: 1),
                          const SizedBox(height: 32),

                          // ── Reviews (dynamic, per-product) ───────────
                          _ReviewSummarySection(
                            reviews: reviews,
                            averageRating: widget.furniture.rating,
                          ),
                          const SizedBox(height: 28),

                          // ── User Reviews List ───────────
                          if (reviews.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Text(
                                'No reviews yet. Be the first to review!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            ...reviews.take(2).map(
                              (r) => _ReviewTile(
                                name: r.reviewerName,
                                review: r.text,
                                rating: r.rating,
                                date: '2 days ago', // Mocked date as requested
                              ),
                            ),
                          
                          if (reviews.length > 2)
                            TextButton(
                              onPressed: () {},
                              child: Text('View all ${reviews.length} reviews', style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),

                          const SizedBox(height: 32),

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
                          const SizedBox(height: 48),

                          // ═══════════════════════════════════════════════
                          // 5. AI PRODUCT FINDER
                          // ═══════════════════════════════════════════════
                          const _AIProductFinderSection(),
                          const SizedBox(height: 48),

                          // ═══════════════════════════════════════════════
                          // 6. PRODUCT RECOMMENDATIONS
                          // ═══════════════════════════════════════════════
                          const _ProductRecommendationsSection(),
                          const SizedBox(height: 140), // Bottom spacing equal to CTA height + breathing space
                        ],
                      ),
                    ),
                  ),
                ),
              ], // Closes children at 226
            ), // Closes Column at 224
          ), // Closes SingleChildScrollView at 223

          // ─── Top floating glass buttons ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
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

          // ─── Bottom Gradient Fade ──────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 180, // Slightly taller for smoother fade
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0.0),
                      AppColors.background.withValues(alpha: 0.6),
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 1), // Subtle top hairline
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 50,
                        spreadRadius: 2,
                        offset: const Offset(0, -12),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), // Reduced vertical padding
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Add to Cart (secondary) ────────────────────
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTapDown: (_) => setState(() => _isCartPressed = true),
                                onTapUp: (_) => setState(() => _isCartPressed = false),
                                onTapCancel: () => setState(() => _isCartPressed = false),
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  if (_redirectGuestToGetStarted()) {
                                    return;
                                  }
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
                                child: AnimatedScale(
                                  scale: _isCartPressed ? 0.96 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.5),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Add to Cart',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ── View in AR (primary) ───────────────────
                          Expanded(
                            flex: 2,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTapDown: (_) => setState(() => _isARPressed = true),
                                onTapUp: (_) => setState(() => _isARPressed = false),
                                onTapCancel: () => setState(() => _isARPressed = false),
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                },
                                child: AnimatedScale(
                                  scale: _isARPressed ? 0.96 : 1.0,
                                  duration: const Duration(milliseconds: 100),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFF8C42).withValues(alpha: 0.9),
                                          AppColors.primary.withValues(alpha: 0.95),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.view_in_ar_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                          Text(
                                            'View in AR',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              height: 1.1,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                            Text(
                                              'Try in your room',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.7),
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w500,
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
            fontSize: 18,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[50]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    row.label,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    row.value,
                                    style: const TextStyle(
                                      fontSize: 13.5,
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

// ─── Reviews Summary Section ──────────────────────────────────────────────────
class _ReviewSummarySection extends StatelessWidget {
  final List<Review> reviews;
  final double averageRating;

  const _ReviewSummarySection({
    required this.reviews,
    required this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    final ratingValue = averageRating.isNaN ? 4.9 : averageRating; // Fallback for mockup if NaN
    final totalReviews = reviews.isNotEmpty ? reviews.length : 128; // Fallback mock

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left score block
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ratingValue.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < ratingValue.round() ? Icons.star : Icons.star_border,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalReviews reviews',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 28),
            // Right bars block
            Expanded(
              child: Column(
                children: const [
                  _RatingBarRow(label: '5', percentage: 0.70),
                  _RatingBarRow(label: '4', percentage: 0.20),
                  _RatingBarRow(label: '3', percentage: 0.07),
                  _RatingBarRow(label: '2', percentage: 0.02),
                  _RatingBarRow(label: '1', percentage: 0.01),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Mock Photo Reviews
        const Text(
          'Photos from buyers',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final mockImages = [
                'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&fit=crop',
                'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=200&fit=crop',
                'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200&fit=crop',
                'https://images.unsplash.com/photo-1505693314120-0d443867891c?w=200&fit=crop',
              ];
              return Container(
                width: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                  image: DecorationImage(
                    image: NetworkImage(mockImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  final String label;
  final double percentage;

  const _RatingBarRow({required this.label, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, color: AppColors.textSecondary, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 4,
                backgroundColor: Colors.grey[100],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Individual Review Card ───────────────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final String name;
  final String review;
  final int rating;
  final String? date;

  const _ReviewTile({
    required this.name,
    required this.review,
    this.rating = 5,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[50]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with avatar, name, date
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    if (date != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        date!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Review Form (Lightweight) ───────────────────────────────────────────
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[50]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write a Review',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Share your thoughts with other customers.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Rating
            Row(
              children: [
                const Text(
                  'Your rating',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    return GestureDetector(
                      onTap: () => onRatingChanged(starIndex),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          starIndex <= rating ? Icons.star : Icons.star_border,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Inputs
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 14),
              decoration: _inputDecoration('Your Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: reviewController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration('What did you like or dislike?'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Submit
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary, // Neutral/Dark organic look
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 13.5,
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
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

// ─── Info Row for Delivery & Warranty ──────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

// ─── AI Product Finder Section ───────────────────────────────────────────────
class _AIProductFinderSection extends StatelessWidget {
  const _AIProductFinderSection();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Product Finder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'AI POWERED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Describe your style or needs, and we\'ll find it.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              // Search Input Mockup (Slimmer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'e.g., minimalist velvet sofa',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Suggested prompts (Smaller)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPromptChip('Minimalist chair'),
                    const SizedBox(width: 8),
                    _buildPromptChip('Modern desk'),
                    const SizedBox(width: 8),
                    _buildPromptChip('Velvet lounge'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // AI Search Button (Elegant)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Search with AI',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ─── Product Recommendations Section ─────────────────────────────────────────
class _ProductRecommendationsSection extends StatelessWidget {
  const _ProductRecommendationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── "Customers also bought" (Horizontal List) ──
        const Text(
          'Customers also bought',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final mockImages = [
                'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=500&fit=crop',
                'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=500&fit=crop',
                'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=500&fit=crop',
                'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=500&fit=crop',
              ];
              final mockTitles = [
                'Minimalist Floor Lamp',
                'Modern Side Table',
                'Velvet Accent Pillow',
                'Woven Throw Blanket'
              ];
              final mockPrices = ['LKR 12,500', 'LKR 18,900', 'LKR 4,500', 'LKR 7,500'];
              final mockRatings = [4.8, 4.6, 4.9, 4.5];
              final tags = ['Popular', null, null, null];

              return SizedBox(
                width: 155,
                child: _RecommendationCard(
                  imageUrl: mockImages[index],
                  title: mockTitles[index],
                  price: mockPrices[index],
                  rating: mockRatings[index],
                  tagText: tags[index],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 48),

        // ── "Similar products" (2-Column Grid) ──
        const Text(
          'Similar products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.60, 
          ),
          itemBuilder: (context, index) {
            final mockGridImages = [
              'https://images.unsplash.com/photo-1581539250439-c9668d1015c5?w=500&fit=crop',
              'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?w=500&fit=crop',
              'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=500&fit=crop',
              'https://images.unsplash.com/photo-1506898667547-42e22a46e125?w=500&fit=crop',
            ];
            final mockGridTitles = [
              'Classic Ergonomic Chair',
              'Scandinavian Wood Chair',
              'Leather Office Chair',
              'Modern Lounge Chair'
            ];
            final mockGridPrices = ['LKR 115,000', 'LKR 85,000', 'LKR 145,000', 'LKR 132,000'];
            final mockGridRatings = [4.7, 4.5, 4.9, 4.6];

            return _RecommendationCard(
              imageUrl: mockGridImages[index],
              title: mockGridTitles[index],
              price: mockGridPrices[index],
              rating: mockGridRatings[index],
              tagText: index == 0 ? 'Top Pick' : null,
            );
          },
        ),
      ],
    );
  }
}

// ─── Recommendation Card (Responsive for Lists and Grids) ────────────────────
class _RecommendationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final double rating;
  final String? tagText;

  const _RecommendationCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.rating,
    this.tagText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image area
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[50],
                            child: Center(
                              child: Icon(Icons.chair_alt_rounded, color: Colors.grey[300], size: 40),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textSecondary),
                        ),
                      ),
                      if (tagText != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tagText!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Content area
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 38,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quick Add Button (Subtle)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
