import './models/furniture_model.dart';

final furnitureData = [
  Furniture(
    id: 1,
    name: "The sofa",
    price: 88000,
    brand: "FurnitureMan",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1567016432779-1fee89b58389?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:90 W:200 D:100",
  ),
  Furniture(
    id: 2,
    name: "Sofa Max",
    price: 100000,
    brand: "Arpico",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:95 W:220 D:105",
  ),
  Furniture(
    id: 3,
    name: "Sofa Lite",
    price: 54000,
    brand: "Damro",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1618220179428-22790b461013?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:85 W:180 D:90",
  ),
];

final categories = ["Arpico", "Damro", "Best sellers", "Minimalistic", "New", "Modern"];
