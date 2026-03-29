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
        name: (json['name'] ?? json['color'] ?? 'Unknown').toString().trim(),
        hex: (json['hex'] ?? json['hex_code'] ?? '').toString().trim(),
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

    // 1. Try imagesByColor[firstColor]
    if (colors.isNotEmpty) {
      final firstColor = colors.first.name.trim();
      if (imagesByColor.containsKey(firstColor) && 
          imagesByColor[firstColor]!.isNotEmpty && 
          imagesByColor[firstColor]!.first.isNotEmpty) {
        chosen = imagesByColor[firstColor]!.first;
        source = "imagesByColor[$firstColor]";
      }
    }

    // 2. Fallback: first non-empty imagesByColor entry
    if ((chosen == null || chosen.isEmpty) && imagesByColor.isNotEmpty) {
      for (var entry in imagesByColor.entries) {
        if (entry.value.isNotEmpty && entry.value.first.isNotEmpty) {
          chosen = entry.value.first;
          source = "imagesByColor[fallback: ${entry.key}]";
          break;
        }
      }
    }

    // 6. Fallback (Final): imageUrl
    if ((chosen == null || chosen.isEmpty) && imageUrl.isNotEmpty) {
      final firstValid = imageUrl.where((e) => e.isNotEmpty).firstOrNull;
      if (firstValid != null) {
        chosen = firstValid;
        source = "imageUrl";
      }
    }

    // 7. LAST RESORT: Smart ID Reconstruction (for missing DB images)
    if ((chosen == null || chosen.isEmpty) && id.isNotEmpty && !id.contains(RegExp(r'^[0-9]+$'))) {
      // Products like 'oaknest-coffee-table' usually follow this pattern
      chosen = 'https://firebasestorage.googleapis.com/v0/b/pocketroom-80f62.firebasestorage.app/o/Images%2Fproducts%2F$id%2Fimage1.webp?alt=media';
      source = "Reconstructed(webp)";
    }

    // Logging for failure or debugging
    if (chosen == null || chosen.isEmpty) {
      debugPrint('--- IMAGE FAILURE: $name ---');
      debugPrint('Colors: ${colors.map((c) => c.name).toList()}');
      debugPrint('ImagesByColor Keys: ${imagesByColor.keys.toList()}');
      debugPrint('ImageUrl: $imageUrl');
      debugPrint('Chosen: $chosen');
      debugPrint('--------------------------');
    }

    return chosen;
  }

  List<String> getDisplayImages(String? selectedColor) {
    final List<String> colorImages = [];
    final String? targetColor = selectedColor?.trim() ?? (colors.isNotEmpty ? colors.first.name.trim() : null);

    // 1. & 2. & 3. Try imagesByColor logic
    if (targetColor != null && imagesByColor.containsKey(targetColor) && imagesByColor[targetColor]!.isNotEmpty) {
      colorImages.addAll(imagesByColor[targetColor]!);
    } else if (imagesByColor.isNotEmpty) {
      // Fallback to first non-empty imagesByColor entry
      for (var entry in imagesByColor.entries) {
        if (entry.value.isNotEmpty) {
          colorImages.addAll(entry.value);
          break;
        }
      }
    }

    // 4. Append common images (imageUrl) AFTER color-specific images
    final List<String> result = [...colorImages, ...imageUrl];

    // Ensure unique and non-empty
    final finalImages = result.where((e) => e.isNotEmpty).toSet().toList();

    if (finalImages.isEmpty) {
      debugPrint('--- CAROUSEL FAILURE: $name ---');
      debugPrint('Selected Color: $selectedColor');
      debugPrint('ImagesByColor Keys: ${imagesByColor.keys.toList()}');
      debugPrint('ImageUrl: $imageUrl');
      debugPrint('------------------------------');
    }

    return finalImages;
  }

  factory Furniture.fromJson(Map<String, dynamic> json) {
    final furnitureType = json['furnitureType']?.toString() ?? json['category']?.toString() ?? 'N/A';
    
    String dimensions = 'N/A';
    if (json['dimensions'] is Map) {
      final d = json['dimensions'] as Map;
      final parts = <String>[];
      if (d['height'] != null) parts.add('H:${d['height']} cm');
      if (d['width'] != null) parts.add('W:${d['width']} cm');
      if (d['length'] != null) parts.add('L:${d['length']} cm');
      if (d['depth'] != null) parts.add('D:${d['depth']} cm');
      dimensions = parts.isNotEmpty ? parts.join('  ') : d.toString();
    } else if (json['dimensions'] != null) {
      dimensions = json['dimensions'].toString();
    } else if (json['dimensions_cm'] is Map) {
      final d = json['dimensions_cm'] as Map;
      dimensions = 'L: ${d['l']}cm, W: ${d['w']}cm, H: ${d['h']}cm';
    }

    final rawMaterials = (json['materials'] is List)
        ? (json['materials'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList().cast<String>()
        : ((json['material']?.toString().trim().isNotEmpty ?? false)
            ? [json['material'].toString().trim()]
            : <String>[]);

    final rawImagesByColor = <String, List<String>>{};
    final imagesByColorData = json['imagesByColor'] ?? json['images_by_color'];
    if (imagesByColorData is Map) {
      imagesByColorData.forEach((key, value) {
        if (value is List) {
          rawImagesByColor[key.toString().trim()] = 
              value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList().cast<String>();
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

    // 8. Fallback to 'thumbnail' or 'product_image'
    if (json['thumbnail'] is String && json['thumbnail'].toString().isNotEmpty) rawImageUrl.add(json['thumbnail']);
    if (json['product_image'] is String && json['product_image'].toString().isNotEmpty) rawImageUrl.add(json['product_image']);

    final rawColors = <ProductColor>[];
    final colorsData = json['colors'] ?? json['color'] ?? json['product_color'] ?? json['product_colors'];
    if (colorsData is List) {
      rawColors.addAll(colorsData.map((e) => ProductColor.fromJson(e)));
    } else if (colorsData != null && colorsData.toString().trim().isNotEmpty) {
      rawColors.add(ProductColor.fromJson(colorsData));
    }

    // Capture hex colors if available directly
    if (json['hex_colors'] is List) {
       // ... potential extra logic
    }

    if (rawImageUrl.isEmpty && rawImagesByColor.isEmpty) {
      debugPrint('--- JSON EXTRACTION FAILURE [${json['id']}]: No images found ---');
      debugPrint('Available Keys: ${json.keys.toList()}');
      debugPrint('JSON Content: $json');
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
      furnitureType: furnitureType,
      dimensions: dimensions,
      availability: json['availability']?.toString() ?? 
                   (json['stockStatus'] is bool ? ((json['stockStatus'] as bool) ? 'Available' : 'Unavailable') : 'N/A'),
      styleTags: (json['styleTags'] is List)
          ? (json['styleTags'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
          : const [],
      description: json['description']?.toString() ?? '',
      colors: rawColors,
      imagesByColor: rawImagesByColor,
      similarProducts: (json['similarProducts'] is List)
          ? (json['similarProducts'] as List).map((e) => e.toString()).toList().cast<String>()
          : const [],
      customersAlsoBought: (json['customersAlsoBought'] is List)
          ? (json['customersAlsoBought'] as List).map((e) => e.toString()).toList().cast<String>()
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
