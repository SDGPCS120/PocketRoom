import 'package:flutter/material.dart';
import 'package:pocketroom/src/features/home/data/models/furniture_model.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_image_carousel.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_details_header.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_specifications.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_color_picker.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_materials_chips.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_section_list.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_bottom_bar.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_quantity_selector.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_description.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_reviews_section.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/product_add_review_form.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/web_product_image_gallery.dart';
import 'package:pocketroom/src/features/home/presentation/widgets/product/web_product_actions.dart';

class ProductPage extends StatefulWidget {
  final Furniture furniture;

  const ProductPage({super.key, required this.furniture});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late String _selectedColor;
  late String _selectedMaterial;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedColor =
        widget.furniture.colors.isNotEmpty ? widget.furniture.colors.first.name : '';
    _selectedMaterial =
        widget.furniture.materials.isNotEmpty ? widget.furniture.materials.first : '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1024) {
          return _buildWebLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final f = widget.furniture;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (Scrollable: Gallery + Descriptions + Reviews)
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WebProductImageGallery(
                          furniture: f,
                          selectedColor: _selectedColor,
                        ),
                        const SizedBox(height: 48),
                        if (f.description.isNotEmpty) ...[
                          ProductDescription(description: f.description),
                          const SizedBox(height: 32),
                        ],
                        ProductSpecifications(furniture: f),
                        const SizedBox(height: 32),
                        ProductReviewsSection(productId: f.id),
                        const SizedBox(height: 16),
                        ProductAddReviewForm(productId: f.id),
                        const SizedBox(height: 48),
                        ProductSectionList(
                          title: 'Similar Products',
                          productIds: f.similarProducts,
                        ),
                        const SizedBox(height: 32),
                        ProductSectionList(
                          title: 'Customers Also Bought',
                          productIds: f.customersAlsoBought,
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                // Right Column (Sticky: Info + Actions)
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductDetailsHeader(furniture: f),
                        const SizedBox(height: 32),
                        // Variant Summary
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                            ),
                            children: [
                              const TextSpan(text: 'Selected:  '),
                              TextSpan(
                                text: 'Default • ${_selectedMaterial.isNotEmpty ? _selectedMaterial : 'None'} • Small',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (f.colors.isNotEmpty) ...[
                          ProductColorPicker(
                            colors: f.colors,
                            selectedColor: _selectedColor,
                            onColorSelected: (color) {
                              setState(() => _selectedColor = color);
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                        if (f.materials.isNotEmpty) ...[
                          ProductMaterialsChips(
                            materials: f.materials,
                            selectedMaterial: _selectedMaterial,
                            onMaterialSelected: (material) {
                              setState(() => _selectedMaterial = material);
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                        ProductQuantitySelector(
                          quantity: _quantity,
                          maxQuantity: 3, // Mock max quantity
                          onQuantityChanged: (qty) {
                            setState(() => _quantity = qty);
                          },
                        ),
                        const SizedBox(height: 32),
                        WebProductActions(furniture: f),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final f = widget.furniture;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImageCarousel(
                        furniture: f,
                        selectedColor: _selectedColor,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductDetailsHeader(furniture: f),
                            const SizedBox(height: 32),
                            
                            // Variant Summary
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                                ),
                                children: [
                                  const TextSpan(text: 'Selected:  '),
                                  TextSpan(
                                    text: 'Default • ${_selectedMaterial.isNotEmpty ? _selectedMaterial : 'None'} • Small',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            if (f.colors.isNotEmpty) ...[
                              ProductColorPicker(
                                colors: f.colors,
                                selectedColor: _selectedColor,
                                onColorSelected: (color) {
                                  setState(() => _selectedColor = color);
                                },
                              ),
                              const SizedBox(height: 32),
                            ],
                            
                            if (f.materials.isNotEmpty) ...[
                              ProductMaterialsChips(
                                materials: f.materials,
                                selectedMaterial: _selectedMaterial,
                                onMaterialSelected: (material) {
                                  setState(() => _selectedMaterial = material);
                                },
                              ),
                              const SizedBox(height: 32),
                            ],

                            ProductQuantitySelector(
                              quantity: _quantity,
                              maxQuantity: 3, // Mock max quantity for design
                              onQuantityChanged: (qty) {
                                setState(() => _quantity = qty);
                              },
                            ),
                            const SizedBox(height: 32),

                            if (f.description.isNotEmpty) ...[
                              ProductDescription(description: f.description),
                              const SizedBox(height: 32),
                            ],
                            ProductSpecifications(furniture: f),
                            const SizedBox(height: 32),
                            ProductReviewsSection(productId: f.id),
                            const SizedBox(height: 16),
                            ProductAddReviewForm(productId: f.id),
                            const SizedBox(height: 32),
                            ProductSectionList(
                              title: 'Similar Products',
                              productIds: f.similarProducts,
                            ),
                            const SizedBox(height: 32),
                            ProductSectionList(
                              title: 'Customers Also Bought',
                              productIds: f.customersAlsoBought,
                            ),
                            const SizedBox(height: 120), // Padding for bottom bar
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Fixed Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ProductBottomBar(furniture: f),
          ),
        ],
      ),
    );
  }
}
