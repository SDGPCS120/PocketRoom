import 'package:flutter_riverpod/flutter_riverpod.dart';
import './models/furniture_model.dart';
import './models/vendor_model.dart';
import './repositories/furniture_repository.dart';
import './repositories/firestore_product_repository.dart';

// Provider for the active Furniture Type (selected from Home Page)
final selectedFurnitureTypeProvider = StateProvider<String>((ref) => "All");

// Provider for the active General Category (selected from Category Products Page)
final selectedGeneralCategoryProvider = StateProvider<String>((ref) => "Best sellers");

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
final vendorByNameProvider = FutureProvider.family<Vendor?, String>((ref, name) {
  final repository = ref.watch(furnitureRepositoryProvider);
  return repository.fetchVendorByName(name);
});

// 1d. Vendor Products Fetcher: Fetches products for a specific vendor.
final vendorFurnitureProvider = FutureProvider.family<List<Furniture>, String>((ref, vendorName) {
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
      filtered = filtered.where((item) => item.brand.contains('Arpico')).toList();
      break;
    case 'Modern':
      filtered = filtered.where((item) => _hasStyleTag(item, 'modern')).toList();
      break;
    case 'Max':
      filtered = filtered.where((item) => _hasStyleTag(item, 'max')).toList();
      break;
    case 'Minimalistic':
      filtered = filtered
          .where((item) => _hasStyleTag(item, 'minimalistic'))
          .toList();
      break;
    case 'Damro':
      filtered = filtered.where((item) => item.brand.contains('Damro')).toList();
      break;
    case 'Best sellers':
      // For "Best sellers" or others, just keep the type-filtered items
      break;
  }

  // Then, apply search query filter if it's not empty
  if (searchQuery.isNotEmpty) {
    filtered = filtered
        .where((item) => item.name.toLowerCase().contains(searchQuery) || item.brand.toLowerCase().contains(searchQuery))
        .toList();
  }

  // Finally, apply sorting
  final sorted = List<Furniture>.from(filtered);
  switch (sortOrder) {
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
      // Keep existing order (which might be the default API order)
      break;
  }

  return sorted;
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
  final allFurnitureAsync = ref.watch(allFurnitureProvider);
  return allFurnitureAsync.whenData((list) {
    // Budget Friendly = Price < 50,000
    var budgetItems = list.where((item) => item.price < 50000).toList();
    
    if (budgetItems.length < 2) {
      budgetItems.addAll([
        Furniture(
          id: 'mock_budget_1',
          name: 'Side Table',
          brand: 'ARPICO',
          price: 8500,
          rating: 4.5,
          images: ['https://images.unsplash.com/photo-1533090161767-e6ffed986c88?auto=format&fit=crop&q=80&w=400'],
          furnitureType: 'Table',
          dimensions: '45x45x50 cm',
        ),
        Furniture(
          id: 'mock_budget_2',
          name: 'Study Lamp',
          brand: 'MAX',
          price: 3200,
          rating: 4.7,
          images: ['https://images.unsplash.com/photo-1534073828943-f801091bb18c?auto=format&fit=crop&q=80&w=400'],
          furnitureType: 'Lamp',
          dimensions: '15x15x40 cm',
        ),
      ]);
    }
    return budgetItems;
  });
});

final limitedTimeFurnitureProvider = Provider<AsyncValue<List<Furniture>>>((ref) {
  final allFurnitureAsync = ref.watch(allFurnitureProvider);
  return allFurnitureAsync.whenData((list) {
    // Limited Time = Items with a discount (oldPrice exists and is > price)
    var deals = list.where((item) => item.oldPrice != null && item.oldPrice! > item.price).toList();
    
    // Add mock deals if Firestore yields too few (for demonstration)
    if (deals.length < 2) {
      deals.addAll([
        Furniture(
          id: 'mock_deal_1',
          name: 'Modern Velvet Sofa',
          brand: 'DAMRO',
          price: 95000,
          oldPrice: 125000,
          rating: 4.8,
          images: ['https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&q=80&w=400'],
          furnitureType: 'Sofa',
          dimensions: '210x95x90 cm',
        ),
        Furniture(
          id: 'mock_deal_2',
          name: 'Ergonomic Office Chair',
          brand: 'ARPICO',
          price: 18500,
          oldPrice: 24000,
          rating: 4.6,
          images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400'],
          furnitureType: 'Chair',
          dimensions: '60x60x110 cm',
        ),
        Furniture(
          id: 'mock_deal_3',
          name: 'Minimalist Coffee Table',
          brand: 'MAX',
          price: 12000,
          oldPrice: 18000,
          rating: 4.4,
          images: ['https://images.unsplash.com/photo-1533090161767-e6ffed986c88?auto=format&fit=crop&q=80&w=400'],
          furnitureType: 'Table',
          dimensions: '90x90x40 cm',
        ),
      ]);
    }
    return deals;
  });
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
