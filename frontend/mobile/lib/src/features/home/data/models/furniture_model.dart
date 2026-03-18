import 'package:flutter/material.dart';

class Furniture {
  final String id;
  final String name;
  final double price;
  final double? oldPrice;
  final String brand;
  final double rating;
  final List<String> images;
  final String imageUrl;
  final String imagePath;
  final String modelURL;
  final String material;
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
  final List<Color> colorOptions;

  Furniture({
    required this.id,
    required this.name,
    required this.price,
    this.oldPrice,
    required this.brand,
    required this.rating,
    required this.images,
    this.imageUrl = '',
    this.imagePath = '',
    this.modelURL = '',
    this.material = '',
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
    this.colorOptions = const [],
  });

  factory Furniture.fromJson(Map<String, dynamic> json) {
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
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.nan,
      images: (json['images'] is List)
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : ((json['imageUrl']?.toString().trim().isNotEmpty ?? false)
                ? [json['imageUrl'].toString()]
                : []),
      imageUrl: (json['imageUrl']?.toString().trim().isNotEmpty ?? false)
          ? json['imageUrl'].toString()
          : '',
      imagePath: (json['imagePath']?.toString().trim().isNotEmpty ?? false)
          ? json['imagePath'].toString()
          : '',
      modelURL: (json['modelURL']?.toString().trim().isNotEmpty ?? false)
          ? json['modelURL'].toString()
          : '',
      material: (json['material']?.toString().trim().isNotEmpty ?? false)
          ? json['material'].toString()
          : '',
      modelStatus: (json['modelStatus']?.toString().trim().isNotEmpty ?? false)
          ? json['modelStatus'].toString()
          : '',
      modelError: json['modelError']?.toString() ?? '',
      primaryColor: (json['primaryColor']?.toString().trim().isNotEmpty ?? false)
          ? json['primaryColor'].toString()
          : '',
      productID: (json['productID']?.toString().trim().isNotEmpty ?? false)
          ? json['productID'].toString()
          : (json['id']?.toString() ?? ''),
      stockStatus: json['stockStatus'] is bool ? json['stockStatus'] as bool : null,
      furnitureType:
          (json['furnitureType']?.toString().trim().isNotEmpty ?? false)
          ? json['furnitureType'].toString()
          : 'N/A',
      dimensions: (json['dimensions']?.toString().trim().isNotEmpty ?? false)
          ? json['dimensions'].toString()
          : 'N/A',
      availability:
          (json['availability']?.toString().trim().isNotEmpty ?? false)
          ? json['availability'].toString()
          : (json['stockStatus'] is bool)
          ? ((json['stockStatus'] as bool) ? 'Available' : 'Unavailable')
          : 'N/A',
      styleTags: (json['styleTags'] is List)
          ? (json['styleTags'] as List)
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : const [],
      description: json['description']?.toString() ?? '',
      colorOptions: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'oldPrice': oldPrice,
      'brand': brand,
      'rating': rating,
      'images': images,
      'furnitureType': furnitureType,
      'dimensions': dimensions,
      'availability': availability,
      'styleTags': styleTags,
      'description': description,
    };
  }
}
