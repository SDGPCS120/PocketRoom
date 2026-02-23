class Furniture {
  final String id;
  final String name;
  final double price;
  final String brand;
  final double rating;
  final List<String> images;
  final String furnitureType;
  final String dimensions;

  Furniture({
    required this.id,
    required this.name,
    required this.price,
    required this.brand,
    required this.rating,
    required this.images,
    required this.furnitureType,
    required this.dimensions,
  });

  factory Furniture.fromJson(Map<String, dynamic> json) {
    return Furniture(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      brand: json['brand']?.toString() ?? '',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      images: (json['images'] is List)
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : [],
      furnitureType: json['furnitureType']?.toString() ?? '',
      dimensions: json['dimensions']?.toString() ?? '',
    );
  }
}
