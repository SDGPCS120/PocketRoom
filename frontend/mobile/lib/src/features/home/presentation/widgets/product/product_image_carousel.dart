import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import 'package:share_plus/share_plus.dart';

/// A premium, swipeable image carousel for the product detail page.
/// Supports network, asset, and AVIF images with smooth animations,
/// gradient overlay, animated dots, and floating action buttons.
class ProductImageCarousel extends ConsumerStatefulWidget {
  final Furniture furniture;
  final String selectedColor;

  const ProductImageCarousel({
    super.key,
    required this.furniture,
    required this.selectedColor,
  });

  @override
  ConsumerState<ProductImageCarousel> createState() =>
      _ProductImageCarouselState();
}

class _ProductImageCarouselState extends ConsumerState<ProductImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(ProductImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to first image when color selection changes
    if (oldWidget.selectedColor != widget.selectedColor) {
      setState(() => _currentPage = 0);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getDisplayImages() {
    return widget.furniture.getDisplayImages(widget.selectedColor);
  }

  bool _isNetworkUrl(String path) => path.startsWith('http');

  /// Builds the canonical URL for this product.
  /// On Flutter Web, reads the actual browser URL first.
  /// Falls back to a constructed deep-link URL.
  String _buildProductUrl(Furniture f) {
    if (kIsWeb) {
      try {
        final current = Uri.base.toString();
        // If we are already on a product page, use the browser URL
        if (current.contains('/product/')) return current;
        
        final origin = Uri.base.origin;
        // Construct the unique route with product id
        return '$origin/#/product/${f.id}';
      } catch (_) {}
    }
    // Mobile / generic fallback
    return 'https://pocketroom.app/product/${f.id}';
  }

  void _shareProduct(Furniture f) {
    final url = _buildProductUrl(f);
    final price =
        'LKR ${f.price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';

    final text = 'Check out this product on PocketRoom:\n'
        '${f.name}\n'
        '$url\n\n'
        'Price: $price';

    Share.share(
      text,
      subject: 'Review: ${f.name} – PocketRoom',
    );
  }

  Widget _buildImage(String url, ColorScheme colorScheme) {
    final isAvif = url.toLowerCase().contains('.avif');

    if (_isNetworkUrl(url)) {
      if (isAvif) {
        return AvifImage.network(
          url,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
        );
      }
      return Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildLoadingIndicator(
            colorScheme,
            progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!
                : null,
          );
        },
      );
    } else {
      if (isAvif) {
        return AvifImage.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
        );
      }
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
      );
    }
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme, double? value) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          value: value,
          color: colorScheme.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.chair_outlined,
          size: 80,
          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildOverlayButton({
    required Widget child,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.88),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildPaginationDots(
      List<String> images, ColorScheme colorScheme) {
    if (images.length <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(images.length, (i) {
        final isActive = _currentPage == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: isActive ? 8 : 6,
          width: isActive ? 24 : 6,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final f = widget.furniture;
    final displayImages = _getDisplayImages();
    final hasImages = displayImages.isNotEmpty;

    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.any((item) => item.id == f.id);

    final carouselHeight = MediaQuery.of(context).size.height * 0.48;
    final safeTop = MediaQuery.of(context).padding.top + 12;

    return SizedBox(
      height: carouselHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. PAGE VIEW ────────────────────────────────────────────────
          hasImages
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: displayImages.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, index) =>
                      _buildImage(displayImages[index], colorScheme),
                )
              : _buildPlaceholder(colorScheme),

          // ── 2. BOTTOM GRADIENT OVERLAY ──────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: carouselHeight * 0.45,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 3. TOP GRADIENT OVERLAY (for button legibility) ─────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: carouselHeight * 0.22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 4. BACK BUTTON ───────────────────────────────────────────────
          Positioned(
            top: safeTop,
            left: 16,
            child: _buildOverlayButton(
              colorScheme: colorScheme,
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // ── 5. SHARE + WISHLIST BUTTONS (top right) ─────────────────────
          Positioned(
            top: safeTop,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Share button
                _buildOverlayButton(
                  colorScheme: colorScheme,
                  onTap: () => _shareProduct(f),
                  child: Icon(
                    Icons.ios_share_rounded,
                    size: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                // Wishlist button
                _buildOverlayButton(
                  colorScheme: colorScheme,
                  onTap: () {
                    ref.read(favoritesProvider.notifier).toggleFavorite(f);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? '${f.name} removed from favorites'
                              : '${f.name} added to favorites',
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: isFavorite
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.primary,
                      ),
                    );
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFavorite),
                      size: 18,
                      color: isFavorite
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 6. PAGINATION DOTS ───────────────────────────────────────────
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildPaginationDots(displayImages, colorScheme),
          ),

          // ── 7. IMAGE COUNT (subtle badge, top center-right) ──────────────
          if (hasImages && displayImages.length > 1)
            Positioned(
              top: safeTop + 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1} / ${displayImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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
