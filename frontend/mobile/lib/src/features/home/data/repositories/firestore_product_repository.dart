import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/furniture_model.dart';
import '../models/vendor_model.dart';
import 'furniture_repository.dart';

/// Repository that fetches products directly from Cloud Firestore.
class FirestoreProductRepository implements IFurnitureRepository {
  final FirebaseFirestore _firestore;

  FirestoreProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Furniture>> fetchFurniture() async {
    final snapshot = await _firestore.collection('products').get();

    return snapshot.docs.map<Furniture>((doc) {
      final data = doc.data();

      return Furniture(
        id: doc.id,
        name: _asTextOrNA(data['name']),
        price: (data['price'] is num) ? (data['price'] as num).toDouble() : double.nan,
        oldPrice: (data['oldPrice'] is num) ? (data['oldPrice'] as num).toDouble() : null,
        brand: _asTextOrNA(data['brand']),
        rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : double.nan,
        images: _extractImages(data),
        imagePath: _asOptionalText(data['imagePath']),
        modelURL: _asOptionalText(data['modelURL']),
        material: _asOptionalText(data['material']),
        modelStatus: _asOptionalText(data['modelStatus']),
        modelError: data['modelError']?.toString() ?? '',
        primaryColor: _asOptionalText(data['primaryColor']),
        productID: _asOptionalText(data['productID']).isNotEmpty
            ? _asOptionalText(data['productID'])
            : doc.id,
        stockStatus: data['stockStatus'] is bool ? data['stockStatus'] as bool : null,
        furnitureType: data['furnitureType']?.toString() ?? 'N/A',
        dimensions: _asTextOrNA(data['dimensions']),
        availability: _availabilityLabel(data['stockStatus']),
        styleTags: _extractStyleTags(data['styleTags']),
        description: _asOptionalText(data['description']),
      );
    }).toList();
  }

  @override
  Future<List<Vendor>> fetchVendors() async {
    // Try to fetch from 'vendors' collection first
    try {
      final snapshot = await _firestore.collection('vendors').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Vendor.fromJson({...doc.data(), 'id': doc.id})).toList();
      }
    } catch (e) {
      // Fallback to deriving from products
    }

    // Derive from products
    final products = await fetchFurniture();
    final brands = products.map((p) => p.brand).toSet();
    
    return brands.map((brand) => Vendor(
      id: brand.toLowerCase().replaceAll(' ', '_'),
      name: brand,
      description: 'Find the best collection from $brand at PocketRoom.',
      rating: 4.5, // Default rating
    )).toList();
  }

  @override
  Future<List<Furniture>> fetchFurnitureByVendor(String vendorName) async {
    final products = await fetchFurniture();
    return products.where((p) => p.brand.toLowerCase() == vendorName.toLowerCase()).toList();
  }

  @override
  Future<Vendor?> fetchVendorByName(String name) async {
    final vendors = await fetchVendors();
    try {
      return vendors.firstWhere((v) => v.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  String _asTextOrNA(dynamic value) {
    if (value == null) {
      return 'N/A';
    }
    final text = value.toString().trim();
    return text.isEmpty ? 'N/A' : text;
  }

  String _asOptionalText(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  String _availabilityLabel(dynamic stockStatus) {
    if (stockStatus is bool) {
      return stockStatus ? 'Available' : 'Unavailable';
    }
    return 'N/A';
  }

  List<String> _extractImages(Map<String, dynamic> data) {
    if (data['imageUrl'] is List) {
      return (data['imageUrl'] as List)
          .map((e) => e.toString().trim())
          .where((url) => url.isNotEmpty)
          .toList();
    }
    
    if (data['images'] is List) {
      return (data['images'] as List)
          .map((e) => e.toString().trim())
          .where((url) => url.isNotEmpty)
          .toList();
    }

    final imageUrl = data['imageUrl'];
    if (imageUrl != null && imageUrl is String) {
      final single = imageUrl.trim();
      if (single.isNotEmpty) {
        return [single];
      }
    }

    return const [];
  }

  String _extractImageUrl(Map<String, dynamic> data) {
    if (data['imageUrl'] is List) {
      final arr = data['imageUrl'] as List;
      if (arr.isNotEmpty) {
        return arr.first.toString().trim();
      }
    }
    
    final imageUrl = data['imageUrl'];
    if (imageUrl != null && imageUrl is String) {
      return imageUrl.trim();
    }
    return '';
  }

  List<String> _extractStyleTags(dynamic rawTags) {
    if (rawTags is List) {
      return rawTags
          .map((e) => e.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
