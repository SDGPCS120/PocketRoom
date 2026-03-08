import 'package:flutter_riverpod/flutter_riverpod.dart';
import './models/furniture_model.dart';
import './repositories/furniture_repository.dart';
import './repositories/firestore_product_repository.dart';

// Provider for the active Furniture Type (selected from Home Page)
final selectedFurnitureTypeProvider = StateProvider<String>((ref) => "All");

// Provider for the active General Category (selected from Category Products Page)
final selectedGeneralCategoryProvider = StateProvider<String>((ref) => "Best sellers");

// Provider for the repository — now uses the API-backed implementation.
final furnitureRepositoryProvider = Provider<IFurnitureRepository>((ref) {
  return FirestoreProductRepository();
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
    filtered = filtered
        .where((item) => _matchesFurnitureType(item, activeType))
        .toList();
  }

  // Then, filter by General Category
  // Categories: ["Best sellers", "Arpico", "Modern", "Max", "Minimalistic", "Damro"]
  switch (activeCategory) {
    case 'Arpico':
      return filtered.where((item) => item.brand.contains('Arpico')).toList();
    case 'Modern':
      return filtered.where((item) => _hasStyleTag(item, 'modern')).toList();
    case 'Max':
      return filtered.where((item) => _hasStyleTag(item, 'max')).toList();
    case 'Minimalistic':
      return filtered
          .where((item) => _hasStyleTag(item, 'minimalistic'))
          .toList();
    case 'Damro':
      return filtered.where((item) => item.brand.contains('Damro')).toList();
    case 'Best sellers':
    default:
      // For "Best sellers" or others, maybe return all type-filtered items?
      return filtered;
  }
});

bool _matchesFurnitureType(Furniture item, String activeType) {
  final selected = _normalize(activeType);
  final itemType = _normalize(item.furnitureType);
  final itemName = _normalize(item.name);

  if (itemType == selected) {
    return true;
  }

  final aliases = _typeAliases[selected] ?? <String>{selected};
  if (aliases.contains(itemType)) {
    return true;
  }

  return aliases.any((alias) => itemName.contains(alias));
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}

const Map<String, Set<String>> _typeAliases = {
  'sofa': {'sofa', 'sofas', 'couch', 'couches'},
  'chair': {'chair', 'chairs', 'seat', 'seating'},
  'table': {'table', 'tables', 'desk', 'desks'},
  'lamp': {'lamp', 'lamps', 'light', 'lights'},
};

bool _hasStyleTag(Furniture item, String requiredTag) {
  final target = _normalize(requiredTag);
  return item.styleTags.any((tag) => _normalize(tag) == target);
}
