import 'package:flutter_riverpod/flutter_riverpod.dart';
import './models/furniture_model.dart';
import './repositories/furniture_repository.dart';

// Provider for the active category (unchanged).
final activeCategoryProvider = StateProvider<String>((ref) => "Best sellers");

// Provider for the repository itself. This allows us to easily swap
// the implementation for testing or different data sources.
final furnitureRepositoryProvider = Provider<IFurnitureRepository>((ref) {
  return FurnitureRepository();
});

// The main provider that the UI will interact with.
// It's now a FutureProvider that depends on both the repository and the active category.
final furnitureListProvider = FutureProvider<List<Furniture>>((ref) async {
  // Watch the repository provider to get the repository instance.
  final repository = ref.watch(furnitureRepositoryProvider);

  // Watch the active category. When this changes, this provider will automatically re-run.
  final activeCategory = ref.watch(activeCategoryProvider);

  // Fetch all furniture from the repository.
  final allFurniture = await repository.fetchFurniture();

  // In a real application, you would pass the activeCategory to your repository,
  // e.g., `repository.fetchFurniture(category: activeCategory)`, and the API 
  // would handle the filtering on the backend.
  //
  // Since we are using mock data, we'll simulate the filtering logic here.
  if (activeCategory == 'Minimalistic') {
    // Return only items that contain 'Lite' in their name
    return allFurniture.where((item) => item.name.contains('Lite')).toList();
  }

  if (activeCategory == 'Damro') {
    // Return only items that contain 'Lite' in their name
    return allFurniture.where((item) => item.brand.contains('Damro')).toList();
  }

  if (activeCategory == 'Arpico') {
    // Return only items that contain 'Lite' in their name
    return allFurniture.where((item) => item.brand.contains('Arpico')).toList();
  }

  if (activeCategory == 'Max') {
    // Return only items that contain 'Max' in their name
    return allFurniture.where((item) => item.name.contains('Max')).toList();
  }

  // For "Best sellers" or any other category, we'll return all items for now.
  return allFurniture;
});
