class Furniture {
  final int id;
  final String name;
  final double price;
  final String brand;
  final double rating;
  final List<String> images; // Changed to a list of strings
  final String furnitureType;
  final String dimensions;

  Furniture({
    required this.id,
    required this.name,
    required this.price,
    required this.brand,
    required this.rating,
    required this.images, // Updated constructor
    required this.furnitureType,
    required this.dimensions,
  });
}
