import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/data/models/furniture_model.dart';
import '../../../home/presentation/providers/home_provider.dart';

final _featuredItemNames = {
  'Minimalist Coffee Table',
  'Modern Leather Sofa',
  'Industrial Bookshelf',
  'Nody Clown Chair',
  'Dining Table by Mora Wood',
  'Nordic Lounge Chair',
  'Scandinavian Dining Table',
};

final featuredCollectionProvider = Provider<AsyncValue<List<Furniture>>>((ref) {
  final allFurnitureAsync = ref.watch(allFurnitureProvider);
  return allFurnitureAsync.whenData((list) {
    return list.where((item) => _featuredItemNames.contains(item.name.trim())).toList();
  });
});
