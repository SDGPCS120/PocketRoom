import '../models/furniture_model.dart';
import '../models/vendor_model.dart';
import '../mock_data.dart';

// This is the contract that any furniture repository must follow.
// Using an abstract class makes it easy to swap implementations (e.g., for testing).
abstract class IFurnitureRepository {
  Future<List<Furniture>> fetchFurniture();
  Future<List<Vendor>> fetchVendors();
  Future<List<Furniture>> fetchFurnitureByVendor(String vendorName);
  Future<Vendor?> fetchVendorByName(String name);
}

class FurnitureRepository implements IFurnitureRepository {
  @override
  Future<List<Furniture>> fetchFurniture() async {
    // Simulate a network delay of 1 second.
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, you would make an API call here.
    // For now, we just return the hardcoded mock data.
    return furnitureData;
  }

  @override
  Future<List<Vendor>> fetchVendors() async {
    final brands = furnitureData.map((p) => p.brand).toSet();
    return brands
        .map((brand) => Vendor(
              id: brand.toLowerCase().replaceAll(' ', '_'),
              name: brand,
              description: 'Exclusive furniture collection from $brand.',
              rating: 4.8,
            ))
        .toList();
  }

  @override
  Future<List<Furniture>> fetchFurnitureByVendor(String vendorName) async {
    return furnitureData
        .where((p) => p.brand.toLowerCase() == vendorName.toLowerCase())
        .toList();
  }

  @override
  Future<Vendor?> fetchVendorByName(String name) async {
    final vendors = await fetchVendors();
    try {
      return vendors
          .firstWhere((v) => v.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}

