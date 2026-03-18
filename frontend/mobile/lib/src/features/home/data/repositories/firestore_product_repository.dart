import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/furniture_model.dart';
import 'furniture_repository.dart';

/// Repository that fetches products directly from Cloud Firestore.
class FirestoreProductRepository implements IFurnitureRepository {
  final FirebaseFirestore _firestore;

  FirestoreProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Furniture>> fetchFurniture() async {
    final snapshot = await _firestore.collection('products').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Furniture(
        id: doc.id,
        name: _asTextOrNA(data['name']),
        price: (data['price'] is num)
            ? (data['price'] as num).toDouble()
            : double.nan,
        brand: _asTextOrNA(data['brand']),
        rating:
            (data['rating'] is num)
                ? (data['rating'] as num).toDouble()
                : double.nan,
        images:
            _extractImages(data),
        imageUrl: _extractImageUrl(data),
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
        furnitureType: _asTextOrNA(data['furnitureType']),
        dimensions: _asTextOrNA(data['dimensions']),
        availability: _availabilityLabel(data['stockStatus']),
        styleTags: _extractStyleTags(data['styleTags']),
      );
    }).toList();
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
