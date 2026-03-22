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
      // Ensure ID is included for fromJson
      return Furniture.fromJson({...data, 'id': doc.id});
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

  Map<String, List<String>> _extractImagesByColor(Map<String, dynamic> data) {
    final Map<String, List<String>> result = {};
    final dynamic ibc = data['imagesByColor'] ?? data['images_by_color'];

    if (ibc is Map) {
      ibc.forEach((key, value) {
        if (value is List) {
          result[key.toString().trim()] = value
              .map((e) => e.toString().trim())
              .where((url) => url.isNotEmpty)
              .toList();
        } else if (value is String && value.toString().trim().isNotEmpty) {
          result[key.toString().trim()] = [value.toString().trim()];
        }
      });
    }
    return result;
  }

  List<String> _extractMaterials(Map<String, dynamic> data) {
    if (data['materials'] is List) {
      return (data['materials'] as List)
          .map((e) => e.toString().trim())
          .where((m) => m.isNotEmpty)
          .toList();
    }
    final singleMat = _asOptionalText(data['material']);
    return singleMat.isNotEmpty ? [singleMat] : const [];
  }

  List<String> _extractList(dynamic rawList) {
    if (rawList is List) {
      return rawList
          .map((e) => e.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
