import 'package:flutter_riverpod/flutter_riverpod.dart';
import './models/furniture_model.dart';
import './mock_data.dart';

final activeCategoryProvider = StateProvider<String>((ref) => "Best sellers");

final furnitureProvider = Provider<List<Furniture>>((ref) => furnitureData);
