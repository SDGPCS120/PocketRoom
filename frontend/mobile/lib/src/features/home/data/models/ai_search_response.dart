import 'furniture_model.dart';

/// Response model for AI search API
class AiSearchResponse {
  final String query;
  final String semanticMode;
  final int count;
  final List<AiSearchResultItem> results;

  const AiSearchResponse({
    required this.query,
    required this.semanticMode,
    required this.count,
    required this.results,
  });

  factory AiSearchResponse.fromJson(Map<String, dynamic> json) {
    return AiSearchResponse(
      query: json['query'] as String,
      semanticMode: json['semantic_mode'] as String,
      count: json['count'] as int,
      results: (json['results'] as List<dynamic>)
          .map((item) => AiSearchResultItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Individual search result item
class AiSearchResultItem {
  final double score;
  final List<String> matchedTags;
  final AiSearchProduct product;

  const AiSearchResultItem({
    required this.score,
    required this.matchedTags,
    required this.product,
  });

  factory AiSearchResultItem.fromJson(Map<String, dynamic> json) {
    return AiSearchResultItem(
      score: (json['score'] as num).toDouble(),
      matchedTags: (json['matchedTags'] as List<dynamic>)
          .map((tag) => tag as String)
          .toList(),
      product: AiSearchProduct.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  /// Convert to Furniture model for display
  Furniture toFurniture() => product.toFurniture();
}

/// Product model from AI search backend
class AiSearchProduct {
  final int id;
  final String name;
  final num price;
  final String furnitureType;
  final String color;
  final String material;
  final String style;
  final String description;
  final String image;
  final String brand;
  final num rating;
  final Map<String, dynamic>? dimensionsCm;

  const AiSearchProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.furnitureType,
    required this.color,
    required this.material,
    required this.style,
    required this.description,
    required this.image,
    required this.brand,
    required this.rating,
    this.dimensionsCm,
  });

  factory AiSearchProduct.fromJson(Map<String, dynamic> json) {
    // Handle id as String (e.g., "P001") and convert to int
    final dynamic idValue = json['id'];
    int parsedId = 0;
    if (idValue is String) {
      final numericPart = idValue.replaceAll(RegExp(r'[^0-9]'), '');
      parsedId = numericPart.isNotEmpty ? int.parse(numericPart) : 0;
    } else if (idValue is num) {
      parsedId = idValue.toInt();
    }

    // Robust image extraction (similar to Furniture.fromJson)
    final List<String> rawImages = [];
    
    void addImage(dynamic val) {
      if (val is List) {
        rawImages.addAll(val.map((e) => e.toString().trim()).where((e) => e.isNotEmpty));
      } else if (val is String && val.trim().isNotEmpty) {
        rawImages.add(val.trim());
      }
    }

    addImage(json['imageUrl']);
    addImage(json['image_url']);
    addImage(json['images']);
    addImage(json['image']);
    addImage(json['imagePath']);
    addImage(json['image_path']);
    addImage(json['imageURL']);

    final String primaryImage = rawImages.isNotEmpty ? rawImages.first : '';

    return AiSearchProduct(
      id: parsedId,
      name: json['name'] as String? ?? 'Suggested Product',
      price: json['price'] as num? ?? 0.0,
      furnitureType: json['furnitureType'] as String? ?? json['category'] as String? ?? 'Furniture',
      color: json['color'] as String? ?? '',
      material: json['material'] as String? ?? '',
      style: json['style'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: primaryImage,
      brand: json['brand'] as String? ?? 'Unknown',
      rating: json['rating'] as num? ?? 0.0,
      dimensionsCm: json['dimensions_cm'] as Map<String, dynamic>?,
    );
  }

  /// Convert to existing Furniture model for UI compatibility
  Furniture toFurniture() {
    // Format dimensions from backend format to display format
    String formattedDimensions = 'N/A';
    if (dimensionsCm != null) {
      final l = dimensionsCm!['l'];
      final w = dimensionsCm!['w'];
      final h = dimensionsCm!['h'];
      formattedDimensions = 'L: ${l}cm, W: ${w}cm, H: ${h}cm';
    }

    return Furniture(
      id: id.toString(),
      name: name,
      price: price.toDouble(),
      brand: brand,
      rating: rating.toDouble(),
      imageUrl: image.isNotEmpty ? [image] : const [],
      furnitureType: furnitureType,
      dimensions: formattedDimensions,
      materials: material.isNotEmpty ? [material] : const [],
      colors: color.isNotEmpty ? [color] : const [],
      imagesByColor: (color.isNotEmpty && image.isNotEmpty) ? {color: [image]} : const {},
    );
  }
}
