import 'package:flutter_riverpod/flutter_riverpod.dart';
import './models/furniture_model.dart';
import './repositories/furniture_repository.dart';

// Provider for the active Furniture Type (selected from Home Page)
final selectedFurnitureTypeProvider = StateProvider<String>((ref) => "All");

// Provider for the active General Category (selected from Category Products Page)
final selectedGeneralCategoryProvider = StateProvider<String>((ref) => "Best sellers");

// Provider for the repository itself (unchanged).
final furnitureRepositoryProvider = Provider<IFurnitureRepository>((ref) {
  return FurnitureRepository();
});

// 1. "Fetcher" Provider: Fetches all furniture from the repository ONCE.
final allFurnitureProvider = FutureProvider<List<Furniture>>((ref) {
  final repository = ref.watch(furnitureRepositoryProvider);
  return repository.fetchFurniture();
});

// 2. "Filterer" Provider: Filters by BOTH Furniture Type AND General Category
final filteredFurnitureProvider = Provider<List<Furniture>>((ref) {
  final allFurniture = ref.watch(allFurnitureProvider).value ?? [];
  final activeType = ref.watch(selectedFurnitureTypeProvider);
  final activeCategory = ref.watch(selectedGeneralCategoryProvider);

  // First, filter by Furniture Type (if not "All")
  var filtered = allFurniture;
  if (activeType != 'All') {
    filtered = filtered.where((item) => item.furnitureType == activeType).toList();
  }

  // Then, filter by General Category
  // Categories: ["Best sellers", "Arpico", "Modern", "Max", "Minimalistic", "Damro"]
  switch (activeCategory) {
    case 'Arpico':
      return filtered.where((item) => item.brand.contains('Arpico')).toList();
    case 'Modern':
      return filtered.where((item) => item.name.contains('Modern')).toList();
    case 'Max':
      return filtered.where((item) => item.name.contains('Max')).toList();
    case 'Minimalistic':
      return filtered.where((item) => item.name.contains('Lite')).toList(); // Assuming Lite means Minimalistic
    case 'Damro':
      return filtered.where((item) => item.brand.contains('Damro')).toList();
    case 'Best sellers':
    default:
      // For "Best sellers" or others, maybe return all type-filtered items?
      return filtered;
  }
});
