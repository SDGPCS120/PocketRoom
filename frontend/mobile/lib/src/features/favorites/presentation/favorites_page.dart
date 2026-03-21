import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketroom/src/core/theme/app_theme.dart';
import 'providers/favorites_provider.dart';
import 'widgets/favorites_empty_state.dart';
import 'widgets/favorites_grid.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const FavoritesEmptyState()
          : FavoritesGrid(favorites: favorites),
    );
  }
}
