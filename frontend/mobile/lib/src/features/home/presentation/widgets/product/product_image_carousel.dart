import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/furniture_model.dart';

class ProductImageCarousel extends StatefulWidget {
  final Furniture furniture;

  const ProductImageCarousel({super.key, required this.furniture});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.furniture;
    final hasImages = f.images.isNotEmpty;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 340,
          child: hasImages
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: f.images.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    return Image.network(
                      f.images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.secondary,
                        child: const Icon(Icons.chair, size: 80, color: AppColors.textSecondary),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.secondary,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        );
                      },
                    );
                  },
                )
              : Container(
                  color: AppColors.secondary,
                  child: const Icon(Icons.chair, size: 80, color: AppColors.textSecondary),
                ),
        ),
        if (hasImages && f.images.length > 1)
          Positioned(
            bottom: 34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(f.images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 7,
                  width: _currentPage == i ? 22 : 7,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? AppColors.primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
