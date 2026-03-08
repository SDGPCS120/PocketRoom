class Furniture {
  final String id;
  final String name;
  final double price;
  final String brand;
  final double rating;
  final List<String> images;
  final String furnitureType;
  final String dimensions;
  final String availability;
  final List<String> styleTags;

  Furniture({
    required this.id,
    required this.name,
    required this.price,
    required this.brand,
    required this.rating,
    required this.images,
    required this.furnitureType,
    required this.dimensions,
    this.availability = 'N/A',
    this.styleTags = const [],
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
    );
  }
}
