import 'package:flutter/material.dart';

class Vendor {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final double rating;

  Vendor({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.rating,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'N/A',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }
}
