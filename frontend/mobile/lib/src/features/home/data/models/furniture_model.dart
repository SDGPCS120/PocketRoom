import 'package:flutter/material.dart';

class ProductColor {
  final String name;
  final String hex;

  ProductColor({required this.name, required this.hex});

  factory ProductColor.fromJson(dynamic json) {
    if (json is ProductColor) return json;
    if (json is String) {
      return ProductColor(
        name: json.trim(),
        hex: _getColorHexFromName(json.trim()),
      );
    } else if (json is Map) {
      return ProductColor(
        name: json['name']?.toString() ?? 'Unknown',
        hex: json['hex']?.toString() ?? '',
      );
    }
    return ProductColor(name: 'Unknown', hex: '');
  }

  static String _getColorHexFromName(String name) {
    final n = name.toLowerCase().trim();
    if (n.contains('pink')) return '0xFFFFC0CB';
    if (n.contains('charcoal')) return '0xFF36454F';
    if (n.contains('white')) return '0xFFFFFFFF';
    if (n.contains('beige')) return '0xFFF5F5DC';
    if (n.contains('brown')) return '0xFF8B4513';
    if (n.contains('cream')) return '0xFFFFFDD0';
    if (n.contains('grey') || n.contains('gray')) return '0xFF808080';
    if (n.contains('black')) return '0xFF000000';
    if (n.contains('navy')) return '0xFF000080';
    if (n.contains('blue')) return '0xFF0000FF';
    if (n.contains('tan')) return '0xFFD2B48C';
    if (n.contains('silver')) return '0xFFC0C0C0';
    if (n.contains('oak')) return '0xFF804000';
    if (n.contains('khaki')) return '0xFFF0E68C';
    if (n.contains('ivory')) return '0xFFFFFFF0';
    if (n.contains('yellow')) return '0xFFFFFF00';
    if (n.contains('orange')) return '0xFFFFA500';
    return ''; // Fallback for neutralizing later
  }

  Color toDisplayColor() {
    if (hex.isEmpty) return Colors.grey.shade300;
    try {
      final cleanHex = hex.replaceFirst('#', '').replaceFirst('0x', '');
      if (cleanHex.length == 6) return Color(int.parse('0xFF$cleanHex'));
      if (cleanHex.length == 8) return Color(int.parse('0x$cleanHex'));
      return Colors.grey.shade300;
    } catch (_) {
      return Colors.grey.shade300;
    }
  }
}

class Furniture {
  final String id;
  final String name;
  final double price;
  final double? oldPrice;
  final String brand;
  final String brandLogoUrl;
  final double rating;
  final List<String> imageUrl;
  final String imagePath;
  final String modelURL;
  final String material;
  final List<String> materials;
  final String modelStatus;
  final String modelError;
  final String primaryColor;
  final String productID;
  final bool? stockStatus;
  final String furnitureType;
  final String dimensions;
  final String availability;
  final List<String> styleTags;
  final String description;
  final List<ProductColor> colors;
  final Map<String, List<String>> imagesByColor;
  final List<String> similarProducts;
  final List<String> customersAlsoBought;

  Furniture({
    required this.id,
    required this.name,
    required this.price,
    this.oldPrice,
    required this.brand,
    this.brandLogoUrl = '',
    required this.rating,
    required this.imageUrl,
    this.imagePath = '',
    this.modelURL = '',
    this.material = '',
    this.materials = const [],
    this.modelStatus = '',
    this.modelError = '',
    this.primaryColor = '',
    this.productID = '',
    this.stockStatus,
    required this.furnitureType,
    required this.dimensions,
    this.availability = 'N/A',
    this.styleTags = const [],
    this.description = '',
    List<dynamic> colors = const [],
    this.imagesByColor = const {},
    this.similarProducts = const [],
    this.customersAlsoBought = const [],
  }) : colors = colors.map((e) => ProductColor.fromJson(e)).toList();

  String? getPrimaryImage() {
    String? chosen;
    String source = "none";

    // 1. First try imagesByColor[firstColor]
    if (colors.isNotEmpty) {
      final firstColor = colors.first.name.trim();
      // Try exact match first
      if (imagesByColor.containsKey(firstColor) && imagesByColor[firstColor]!.isNotEmpty) {
        chosen = imagesByColor[firstColor]!.first;
        source = "imagesByColor[exact: $firstColor]";
      } else {
        // Try normalized match
        final normalizedFirst = firstColor.toLowerCase();
        for (var entry in imagesByColor.entries) {
          if (entry.key.trim().toLowerCase() == normalizedFirst && entry.value.isNotEmpty) {
            chosen = entry.value.first;
            source = "imagesByColor[normalized: ${entry.key}]";
            break;
          }
        }
      }
    }

    // 2. Scan ALL keys in imagesByColor if still no image
    if (chosen == null && imagesByColor.isNotEmpty) {
      for (var entry in imagesByColor.entries) {
        if (entry.value.isNotEmpty) {
          chosen = entry.value.first;
          source = "imagesByColor[fallback: ${entry.key}]";
          break;
        }
      }
    }

    // 3. Fallback to imageUrl.first
    if (chosen == null && imageUrl.isNotEmpty) {
      chosen = imageUrl.first;
      source = "imageUrl.first";
    }

    // Temporary Debug Logging
    if (chosen == null || chosen.isEmpty) {
      debugPrint('--- IMAGE FAILURE: $name ---');
      debugPrint('Colors: ${colors.map((c) => c.name).toList()}');
      debugPrint('ImagesByColor Keys: ${imagesByColor.keys.toList()}');
      debugPrint('ImageUrl: $imageUrl');
      debugPrint('--------------------------');
    } else {
      // Optional: success log if you want to see what's working
      // debugPrint('Image Success: $name -> $source ($chosen)');
    }

    return chosen;
  }

  List<String> getDisplayImages(String? selectedColor) {
    final List<String> result = [];
    final String? targetColor = selectedColor?.trim() ?? (colors.isNotEmpty ? colors.first.name.trim() : null);

    if (targetColor != null) {
      // 1. Try exact match
      if (imagesByColor.containsKey(targetColor) && imagesByColor[targetColor]!.isNotEmpty) {
        result.addAll(imagesByColor[targetColor]!);
      } else {
        // 2. Try normalized matching
        final normalizedTarget = targetColor.toLowerCase();
        bool found = false;
        for (var entry in imagesByColor.entries) {
          if (entry.key.trim().toLowerCase() == normalizedTarget) {
            result.addAll(entry.value);
            found = true;
            break;
          }
        }
        
        // 3. If still nothing, move to first available variant
        if (!found && imagesByColor.isNotEmpty) {
          for (var entry in imagesByColor.entries) {
            if (entry.value.isNotEmpty) {
              result.addAll(entry.value);
              break;
            }
          }
        }
      }
    }

    // 4. Append common images from imageUrl
    result.addAll(imageUrl);

    // Ensure unique and non-empty
    final finalImages = result.where((e) => e.isNotEmpty).toSet().toList();

    if (finalImages.isEmpty) {
      debugPrint('--- CAROUSEL FAILURE: $name ---');
      debugPrint('Selected Color: $selectedColor');
      debugPrint('Target Color: $targetColor');
      debugPrint('ImagesByColor Keys: ${imagesByColor.keys.toList()}');
      debugPrint('ImageUrl: $imageUrl');
      debugPrint('------------------------------');
    }

    return finalImages;
  }

  factory Furniture.fromJson(Map<String, dynamic> json) {
    final rawMaterials = (json['materials'] is List)
        ? (json['materials'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : ((json['material']?.toString().trim().isNotEmpty ?? false)
            ? [json['material'].toString().trim()]
            : <String>[]);

    final rawImagesByColor = <String, List<String>>{};
    final imagesByColorData = json['imagesByColor'] ?? json['images_by_color'];
    if (imagesByColorData is Map) {
      imagesByColorData.forEach((key, value) {
        if (value is List) {
          rawImagesByColor[key.toString().trim()] = 
              value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        } else if (value is String && value.trim().isNotEmpty) {
          rawImagesByColor[key.toString().trim()] = [value.trim()];
        }
      });
    }

    final rawImageUrl = <String>[];
    
    // 1. Precise check for 'imageUrl' (List or String)
    if (json['imageUrl'] is List) {
      rawImageUrl.addAll((json['imageUrl'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty));
    } else if (json['imageUrl'] is String && (json['imageUrl'] as String).trim().isNotEmpty) {
      rawImageUrl.add(json['imageUrl'].toString().trim());
    }

    // 2. Fallback to 'images' (List or String)
    if (json['images'] is List) {
      rawImageUrl.addAll((json['images'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty));
    } else if (json['images'] is String && (json['images'] as String).trim().isNotEmpty) {
      rawImageUrl.add(json['images'].toString().trim());
    }

    // 3. Fallback to 'image' (String)
    if (json['image'] is String && (json['image'] as String).trim().isNotEmpty) {
      rawImageUrl.add(json['image'].toString().trim());
    }

    // 4. Fallback to 'imageURL' (Capitalized)
    if (json['imageURL'] is String && (json['imageURL'] as String).trim().isNotEmpty) {
      rawImageUrl.add(json['imageURL'].toString().trim());
    }

    // 6. Fallback to 'imagePath' (As seen in table seed)
    if (json['imagePath'] is String && (json['imagePath'] as String).trim().isNotEmpty) {
      rawImageUrl.add(json['imagePath'].toString().trim());
    }

    // 7. Fallback to 'image_path'
    if (json['image_path'] is String && (json['image_path'] as String).trim().isNotEmpty) {
      rawImageUrl.add(json['image_path'].toString().trim());
    }

    final rawColors = <ProductColor>[];
    final colorsData = json['colors'] ?? json['color'];
    if (colorsData is List) {
      rawColors.addAll(colorsData.map((e) => ProductColor.fromJson(e)));
    } else if (colorsData != null && colorsData.toString().trim().isNotEmpty) {
      rawColors.add(ProductColor.fromJson(colorsData));
    }

    return Furniture(
      id: json['id']?.toString() ?? '',
      name: (json['name']?.toString().trim().isNotEmpty ?? false)
          ? json['name'].toString()
          : 'N/A',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.nan,
      oldPrice: (json['oldPrice'] is num)
          ? (json['oldPrice'] as num).toDouble()
          : null,
      brand: (json['brand']?.toString().trim().isNotEmpty ?? false)
          ? json['brand'].toString()
          : 'N/A',
      brandLogoUrl: json['brandLogoUrl']?.toString() ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.nan,
      imageUrl: rawImageUrl,
      imagePath: json['imagePath']?.toString() ?? '',
      modelURL: json['modelURL']?.toString() ?? '',
      materials: rawMaterials,
      material: (json['material']?.toString().trim().isNotEmpty ?? false)
          ? json['material'].toString()
          : (rawMaterials.isNotEmpty ? rawMaterials.join(', ') : ''),
      modelStatus: json['modelStatus']?.toString() ?? '',
      modelError: json['modelError']?.toString() ?? '',
      primaryColor: json['primaryColor']?.toString() ?? '',
      productID: json['productID']?.toString() ?? (json['id']?.toString() ?? ''),
      stockStatus: json['stockStatus'] is bool ? json['stockStatus'] as bool : null,
      furnitureType: json['furnitureType']?.toString() ?? 'N/A',
      dimensions: json['dimensions']?.toString() ?? 'N/A',
      availability: json['availability']?.toString() ?? 
                   (json['stockStatus'] is bool ? ((json['stockStatus'] as bool) ? 'Available' : 'Unavailable') : 'N/A'),
      styleTags: (json['styleTags'] is List)
          ? (json['styleTags'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
          : const [],
      description: json['description']?.toString() ?? '',
      colors: rawColors,
      imagesByColor: rawImagesByColor,
      similarProducts: (json['similarProducts'] is List)
          ? (json['similarProducts'] as List).map((e) => e.toString()).toList()
          : const [],
      customersAlsoBought: (json['customersAlsoBought'] is List)
          ? (json['customersAlsoBought'] as List).map((e) => e.toString()).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'oldPrice': oldPrice,
      'brand': brand,
      'brandLogoUrl': brandLogoUrl,
      'rating': rating,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'modelURL': modelURL,
      'material': material,
      'materials': materials,
      'modelStatus': modelStatus,
      'modelError': modelError,
      'primaryColor': primaryColor,
      'productID': productID,
      'stockStatus': stockStatus,
      'furnitureType': furnitureType,
      'dimensions': dimensions,
      'availability': availability,
      'styleTags': styleTags,
      'description': description,
      'colors': colors,
      'imagesByColor': imagesByColor,
      'similarProducts': similarProducts,
      'customersAlsoBought': customersAlsoBought,
    };
  }
}
