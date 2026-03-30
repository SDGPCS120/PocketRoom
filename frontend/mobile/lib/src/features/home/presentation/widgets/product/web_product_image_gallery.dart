import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import 'package:share_plus/share_plus.dart';

class WebProductImageGallery extends ConsumerStatefulWidget {
  final Furniture furniture;
  final String selectedColor;

  const WebProductImageGallery({
    super.key,
    required this.furniture,
    required this.selectedColor,
  });

  @override
  ConsumerState<WebProductImageGallery> createState() => _WebProductImageGalleryState();
}

class _WebProductImageGalleryState extends ConsumerState<WebProductImageGallery> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(WebProductImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      setState(() => _currentIndex = 0);
    }
  }

  List<String> _getDisplayImages() => widget.furniture.getDisplayImages(widget.selectedColor);

  bool _isNetworkUrl(String path) => path.startsWith('http');

  String _buildProductUrl(Furniture f) {
    if (kIsWeb) {
      try {
        final current = Uri.base.toString();
        if (current.contains('/product/')) return current;
        final origin = Uri.base.origin;
        return '$origin/#/product/${f.id}';
      } catch (_) {}
    }
    return 'https://pocketroom.app/product/${f.id}';
  }

  void _shareProduct(Furniture f) {
    final url = _buildProductUrl(f);
    final price = 'LKR ${f.price.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';
    final text = 'Check out this product on PocketRoom:\n${f.name}\n$url\n\nPrice: $price';
    Share.share(text, subject: 'Review: ${f.name} – PocketRoom');
  }

  Widget _buildImage(String url, ColorScheme colorScheme, {bool isThumbnail = false}) {
    final isAvif = url.toLowerCase().contains('.avif');

    if (_isNetworkUrl(url)) {
      if (isAvif) {
        return AvifImage.network(
          url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
        );
      }
      return Image.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildLoadingIndicator(
            colorScheme,
            progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          );
        },
      );
    } else {
      if (isAvif) {
        return AvifImage.asset(
          url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
        );
      }
      return Image.asset(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(colorScheme),
      );
    }
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme, double? value) {
    return Container(
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(
          value: value,
          color: colorScheme.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildOverlayButton({
    required Widget child,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Image Display
        AspectRatio(
          aspectRatio: 1.0, // 1:1 ratio for nice square image or 4:3
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasImages
                    ? _buildImage(displayImages[_currentIndex], colorScheme)
                    : _buildPlaceholder(colorScheme),
              ),

              // Overlay Actions
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          color: isFavorite ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Thumbnails
        if (hasImages && displayImages.length > 1)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImage(
                        displayImages[index],
                        colorScheme,
                        isThumbnail: true,
                      ),
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
