import 'package:flutter/material.dart';
import './models/furniture_model.dart';

final furnitureData = [
  Furniture(
    id: '1',
    name: "The Sofa",
    price: 88000,
    oldPrice: 105000,
    brand: "FurnitureMan",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1567016432779-1fee89b58389?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:90 cm  W:200 cm  D:100 cm",
    description:
        "A modern upholstered sofa crafted for everyday comfort. Its deep cushioning and durable fabric finish make it perfect for living rooms, lounges, and open-plan spaces.",
    colorOptions: [
      Color(0xFF2D2D2D),
      Color(0xFFFFFFFF),
      Color(0xFFB5A08A),
    ],
  ),
  Furniture(
    id: '1b',
    name: "The Sofa Classic",
    price: 88000,
    brand: "FurnitureMan",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1567016432779-1fee89b58389?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:90 cm  W:200 cm  D:100 cm",
    description:
        "Timeless classic lines with contemporary upholstery. Sink into plush comfort after a long day.",
    colorOptions: [
      Color(0xFF8B7355),
      Color(0xFFE8D5C4),
    ],
  ),
  Furniture(
    id: '1c',
    name: "The Sofa Slim",
    price: 79000,
    brand: "FurnitureMan",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:86 cm  W:185 cm  D:92 cm",
    description:
        "Space-saving slim profile sofa ideal for apartments and compact living rooms.",
    colorOptions: [
      Color(0xFF4A4A4A),
      Color(0xFFD4C5B5),
    ],
  ),
  Furniture(
    id: '1d',
    name: "The Sofa Corner",
    price: 120000,
    oldPrice: 145000,
    brand: "FurnitureMan",
    rating: 4.2,
    images: [
      "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1567016432779-1fee89b58389?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:90 cm  W:280 cm  D:180 cm",
    description:
        "L-shaped corner sofa for maximum seating. Great for family rooms and home cinema setups.",
    colorOptions: [
      Color(0xFF1C1C1C),
      Color(0xFF7A6552),
      Color(0xFFF5F0EB),
    ],
  ),
  Furniture(
    id: '2',
    name: "Sofa Max",
    price: 100000,
    oldPrice: 120000,
    brand: "Arpico",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:95 cm  W:220 cm  D:105 cm",
    description:
        "The premium Sofa Max delivers unrivalled support and style. High-resilience foam core with hardwood legs.",
    colorOptions: [
      Color(0xFF3E2723),
      Color(0xFF795548),
      Color(0xFFD7CCC8),
    ],
  ),
  Furniture(
    id: '2b',
    name: "Super Sofa Max",
    price: 1000,
    brand: "Damro",
    rating: 1.0,
    images: [
      "https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:95 cm  W:220 cm  D:105 cm",
    description: "Entry-level sofa at a budget-friendly price point.",
    colorOptions: [
      Color(0xFF9E9E9E),
    ],
  ),
  Furniture(
    id: '2c',
    name: "Lite Sofa",
    price: 100000,
    brand: "Damro",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:95 cm  W:220 cm  D:105 cm",
    description:
        "Lightweight construction makes repositioning easy. Durable microfibre upholstery resists everyday wear.",
    colorOptions: [
      Color(0xFF5D4037),
      Color(0xFFEFEBE9),
    ],
  ),
  Furniture(
    id: '2d',
    name: "Sofa Ultra Max",
    price: 100000,
    oldPrice: 115000,
    brand: "Arpico",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:95 cm  W:220 cm  D:105 cm",
    description:
        "Ultra-wide seating for the whole family. Reinforced frame rated for heavy daily use.",
    colorOptions: [
      Color(0xFF212121),
      Color(0xFFBCAAA4),
    ],
  ),
  Furniture(
    id: '2e',
    name: "Sofa Pro Max",
    price: 100000,
    brand: "Arpico",
    rating: 4.0,
    images: [
      "https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=400&h=300&fit=crop",
      "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=400&h=300&fit=crop",
    ],
    furnitureType: "Sofa",
    dimensions: "H:95 cm  W:220 cm  D:105 cm",
    description:
        "Professional-grade comfort meets designer aesthetics. Removable, washable cushion covers included.",
    colorOptions: [
      Color(0xFF37474F),
      Color(0xFF78909C),
      Color(0xFFECEFF1),
    ],
  ),
  Furniture(
    id: '3',
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
    dimensions: "H:85 cm  W:180 cm  D:90 cm",
    description:
        "Compact and versatile, the Sofa Lite fits effortlessly into studios and small apartments without sacrificing style.",
    colorOptions: [
      Color(0xFFE0E0E0),
      Color(0xFF9E9E9E),
    ],
  ),
  Furniture(
    id: '4',
    name: "Classic Chair",
    price: 12000,
    brand: "WoodWorks",
    rating: 4.5,
    images: [
      "https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=400&h=300&fit=crop",
    ],
    furnitureType: "Chair",
    dimensions: "H:90 cm  W:50 cm  D:50 cm",
    description:
        "Solid kiln-dried hardwood frame with a soft fabric seat. Timeless design that complements any interior style.",
    colorOptions: [
      Color(0xFF4E342E),
      Color(0xFF8D6E63),
    ],
  ),
  Furniture(
    id: '5',
    name: "Modern Table",
    price: 45000,
    brand: "Ikea",
    rating: 4.2,
    images: [
      "https://images.unsplash.com/photo-1530018607912-eff2daa1bac4?w=400&h=300&fit=crop",
    ],
    furnitureType: "Table",
    dimensions: "H:75 cm  W:120 cm  D:80 cm",
    description:
        "Clean Scandinavian lines and matte finish make this dining table the centrepiece of any modern kitchen or dining room.",
    colorOptions: [
      Color(0xFFFFFFFF),
      Color(0xFF757575),
      Color(0xFF3E2723),
    ],
  ),
  Furniture(
    id: '6',
    name: "Reading Lamp",
    price: 8500,
    brand: "LumiLux",
    rating: 4.8,
    images: [
      "https://images.unsplash.com/photo-1507473888900-52e1ad145986?w=400&h=300&fit=crop",
    ],
    furnitureType: "Lamp",
    dimensions: "H:150 cm  W:30 cm  D:30 cm",
    description:
        "Adjustable arc floor lamp with warm LED output. Energy-efficient and flicker-free for long reading sessions.",
    colorOptions: [
      Color(0xFF212121),
      Color(0xFFB0BEC5),
    ],
  ),
];

final furnitureTypes = ["All", "Sofa", "Chair", "Table", "Lamp"];

final categories = ["Best sellers", "Arpico", "Modern", "Max", "Minimalistic", "Damro"];
