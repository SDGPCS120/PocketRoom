import '../models/furniture_model.dart';
import '../mock_data.dart';

// This is the contract that any furniture repository must follow.
// Using an abstract class makes it easy to swap implementations (e.g., for testing).
abstract class IFurnitureRepository {
  Future<List<Furniture>> fetchFurniture();
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
}
