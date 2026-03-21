import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/furniture_model.dart';
import '../../../../common_widgets/product_card.dart';
import '../../../../common_widgets/circular_nav_button.dart';
import '../../data/providers.dart';

class ProductList extends ConsumerStatefulWidget {
  final bool isHorizontal;
  final AlwaysAliveProviderBase<AsyncValue<List<Furniture>>>? provider;
  const ProductList({super.key, this.isHorizontal = false, this.provider});

  @override
  ConsumerState<ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {
  late final ScrollController _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    
    final showLeft = _scrollController.offset > 10; // Small threshold
    final showRight = _scrollController.offset < _scrollController.position.maxScrollExtent - 10;
    
    if (showLeft != _showLeftArrow || showRight != _showRightArrow) {
      if (mounted) {
        setState(() {
          _showLeftArrow = showLeft;
          _showRightArrow = showRight;
        });
      }
    }
  }

  void _scroll(double offset) {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If a provider is passed, use it; otherwise, use the default filtered selection.
    final furnitureAsync = widget.provider != null
        ? ref.watch(widget.provider!)
        : ref.watch(allFurnitureProvider).whenData((_) => ref.watch(filteredFurnitureProvider));

    return furnitureAsync.when(
      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => SliverFillRemaining(child: Center(child: Text('Error: $error'))),
      data: (filteredList) {
        // If the filtered list is empty, show a message.
        if (filteredList.isEmpty) {
          return const SliverFillRemaining(
              child: Center(child: Text('No items found in this category.')));
        }

        if (widget.isHorizontal) {
          const horizontalPadding = 20.0;
          const itemSpacing = 16.0;
          final screenWidth = MediaQuery.of(context).size.width;
          final availableWidth = screenWidth - (horizontalPadding * 2);
          
          // Responsive item count
          double itemsVisible;
          if (screenWidth < 600) {
            itemsVisible = 2.14; // Mobile
          } else if (screenWidth < 1000) {
            itemsVisible = 3.14; // Tablet
          } else if (screenWidth < 1400) {
            itemsVisible = 4.14; // Desktop
          } else {
            itemsVisible = 5.14; // Wide Desktop
          }

          final cardWidth = (availableWidth - (itemSpacing * (itemsVisible.floor()))) / itemsVisible;

          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollListener());

          return SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == filteredList.length - 1 ? 0 : itemSpacing,
                          ),
                          child: SizedBox(
                            width: cardWidth,
                            child: ProductCard(furniture: filteredList[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_showLeftArrow)
                    Positioned(
                      left: 6,
                      child: CircularNavButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => _scroll(-(cardWidth + itemSpacing)),
                      ),
                    ),
                  if (_showRightArrow)
                    Positioned(
                      right: 6,
                      child: CircularNavButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        onTap: () => _scroll(cardWidth + itemSpacing),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return _buildSliverGrid(context, filteredList);
      },
    );
  }

  Widget _buildSliverGrid(BuildContext context, List<dynamic> list) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: screenWidth > 600
            ? SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: screenWidth > 1200 ? 200 : 250,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              )
            : const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCard(furniture: list[index]);
          },
          childCount: list.length,
        ),
      ),
    );
  }
}
