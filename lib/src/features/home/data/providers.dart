import 'package:flutter_riverpod/flutter_riverpod.dart';
import './models/furniture_model.dart';
import './repositories/furniture_repository.dart';

// Provider for the active category (unchanged).
final activeCategoryProvider = StateProvider<String>((ref) => "Best sellers");

// Provider for the repository itself (unchanged).
final furnitureRepositoryProvider = Provider<IFurnitureRepository>((ref) {
  return FurnitureRepository();
});

// 1. "Fetcher" Provider: Fetches all furniture from the repository ONCE.
final allFurnitureProvider = FutureProvider<List<Furniture>>((ref) {
  final repository = ref.watch(furnitureRepositoryProvider);
  return repository.fetchFurniture();
});

// 2. "Filterer" Provider: This is a fast, synchronous provider.
// It takes the full list from allFurnitureProvider and filters it based
// on the active category. It re-runs whenever the category changes.
final filteredFurnitureProvider = Provider<List<Furniture>>((ref) {
  final allFurniture = ref.watch(allFurnitureProvider).value ?? [];
  final activeCategory = ref.watch(activeCategoryProvider);

  // --- Restoring your filtering logic here ---
  switch (activeCategory) {
    case 'Arpico':
      return allFurniture.where((item) => item.brand.contains('Arpico')).toList();
    case 'Modern':
      return allFurniture.where((item) => item.name.contains('Sofa')).toList();
    case 'Max':
      return allFurniture.where((item) => item.name.contains('Max')).toList();
    case 'Minimalistic':
      return allFurniture.where((item) => item.name.contains('Lite')).toList();
    case 'Damro':
      return allFurniture.where((item) => item.brand.contains('Damro')).toList();
    default:
      // For all other categories, return the full list.
      return allFurniture;
  }
});
