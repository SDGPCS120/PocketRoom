class Furniture {
  final int id;
  final String name;
  final double price;
  final String brand;
  final double rating;
  final String image;
  final String furnitureType; // e.g., "Sofa", "Chair", "Table"
  final String dimensions;    // e.g., "H: 90cm, W: 200cm, D: 100cm"

  Furniture({
    required this.id,
    required this.name,
    required this.price,
    required this.brand,
    required this.rating,
    required this.image,
    required this.furnitureType,
    required this.dimensions,
  });
}
