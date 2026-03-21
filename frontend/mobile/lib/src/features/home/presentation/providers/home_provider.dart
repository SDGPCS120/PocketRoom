import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/furniture_model.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/mock_data.dart';
import '../../data/repositories/furniture_repository.dart';
import '../../data/repositories/firestore_product_repository.dart';

// Provider for the active Furniture Type (selected from Home Page)
final selectedFurnitureTypeProvider = StateProvider<String>((ref) => "All");

// Provider for the active General Category (selected from Category Products Page)
final selectedGeneralCategoryProvider = StateProvider<String>(
  (ref) => "Best sellers",
);

// Provider for the search query entered in the search bar
final searchQueryProvider = StateProvider<String>((ref) => "");

// Enum for sorting orders
enum SortOrder { none, priceAsc, priceDesc, ratingDesc }

// Provider for the active Sort Order
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.none);

// Provider for the repository — now uses the API-backed implementation.
final furnitureRepositoryProvider = Provider<IFurnitureRepository>((ref) {
  return FirestoreProductRepository();
});

// 1. "Fetcher" Provider: Fetches all furniture from the repository ONCE.
final allFurnitureProvider = FutureProvider<List<Furniture>>((ref) {
  final repository = ref.watch(furnitureRepositoryProvider);
  return repository.fetchFurniture();
});

// 1b. Vendors Fetcher: Fetches all vendors.
final vendorsProvider = FutureProvider<List<Vendor>>((ref) {
  final repository = ref.watch(furnitureRepositoryProvider);
  return repository.fetchVendors();
});

// 1c. Vendor by Name Fetcher: Fetches a single vendor detail.
final vendorByNameProvider =
    FutureProvider.family<Vendor?, String>((ref, name) {
  final repository = ref.watch(furnitureRepositoryProvider);
  return repository.fetchVendorByName(name);
});

// 1d. Vendor Products Fetcher: Fetches products for a specific vendor.
final vendorFurnitureProvider =
    FutureProvider.family<List<Furniture>, String>((ref, vendorName) {
  final repository = ref.watch(furnitureRepositoryProvider);
  return repository.fetchFurnitureByVendor(vendorName);
});

// 2. "Filterer" Provider: Filters by Type, Category, Search Query and Apply Sorting
final filteredFurnitureProvider = Provider<List<Furniture>>((ref) {
  final allFurniture = ref.watch(allFurnitureProvider).value ?? [];
  final activeType = ref.watch(selectedFurnitureTypeProvider);
  final activeCategory = ref.watch(selectedGeneralCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
  final sortOrder = ref.watch(sortOrderProvider);

  var filtered = _applyCategoryFilters(allFurniture, activeType, activeCategory);
  
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((item) => _matchesSearch(item, searchQuery)).toList();
  }

  return _applySorting(filtered, sortOrder);
});

// 3. Specialized Providers for Homepage Sections
final trendingFurnitureProvider = Provider<AsyncValue<List<Furniture>>>((ref) {
  final allFurnitureAsync = ref.watch(allFurnitureProvider);
  return allFurnitureAsync.whenData((list) {
    final sorted = List<Furniture>.from(list);
    // Trending = Highest rated
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(10).toList();
  });
});

final budgetFriendlyFurnitureProvider = Provider<AsyncValue<List<Furniture>>>((ref) {
  return ref.watch(allFurnitureProvider).whenData((list) {
    final budgetItems = list.where((item) => item.price < 50000).toList();
    return budgetItems.isNotEmpty ? budgetItems : mockBudgetProducts;
  });
});

final limitedTimeFurnitureProvider = Provider<AsyncValue<List<Furniture>>>((ref) {
  return ref.watch(allFurnitureProvider).whenData((list) {
    final deals = list.where((item) => item.oldPrice != null && item.oldPrice! > item.price).toList();
    return deals.isNotEmpty ? deals : mockLimitedTimeProducts;
  });
});

List<Furniture> _applyCategoryFilters(List<Furniture> all, String activeType, String activeCategory) {
  var filtered = all;

  // Filter by Furniture Type
  if (activeType != 'All') {
    filtered = filtered.where((item) => _matchesFurnitureType(item, activeType)).toList();
  }

  // Filter by General Category
  switch (activeCategory) {
    case 'Arpico':
      filtered = filtered
          .where((item) => item.brand.contains('Arpico'))
          .toList();
      break;
    case 'Damro':
      filtered = filtered
          .where((item) => item.brand.contains('Damro'))
          .toList();
      break;
    case 'Modern':
    case 'Max':
    case 'Minimalistic':
      filtered = filtered.where((item) => _hasStyleTag(item, activeCategory.toLowerCase())).toList();
      break;
    case 'Best sellers':
    default:
      break;
  }

  return filtered;
}

bool _matchesSearch(Furniture item, String query) {
  return item.name.toLowerCase().contains(query) || 
         item.brand.toLowerCase().contains(query);
}

List<Furniture> _applySorting(List<Furniture> items, SortOrder order) {
  final sorted = List<Furniture>.from(items);
  switch (order) {
    case SortOrder.priceAsc:
      sorted.sort((a, b) => a.price.compareTo(b.price));
      break;
    case SortOrder.priceDesc:
      sorted.sort((a, b) => b.price.compareTo(a.price));
      break;
    case SortOrder.ratingDesc:
      sorted.sort((a, b) => b.rating.compareTo(a.rating));
      break;
    case SortOrder.none:
      break;
  }
  return sorted;
}

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
