import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common_widgets/product_card.dart';
import '../../data/providers.dart';
import '../../data/ai_search_provider.dart';
import '../../data/ai_search_state.dart';

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch AI search state
    final aiSearchState = ref.watch(aiSearchStateProvider);

    // If AI search is active (not initial), show AI results
    if (aiSearchState is! AiSearchInitial) {
      return _buildAiSearchResults(context, ref, aiSearchState);
    }

    // Otherwise, show normal furniture list
    // Watch the "fetcher" provider to handle the initial loading/error states.
    final allFurnitureAsync = ref.watch(allFurnitureProvider);

    return allFurnitureAsync.when(
      loading: () => const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          SliverFillRemaining(child: Center(child: Text('Error: $error'))),
      data: (_) {
        // Once the data has loaded, watch the fast "filterer" provider to get
        // the list that should be displayed.
        final filteredList = ref.watch(filteredFurnitureProvider);

        // If the filtered list is empty, show a message.
        if (filteredList.isEmpty) {
          return const SliverFillRemaining(
              child: Center(child: Text('No items found in this category.')));
        }

        return _buildSliverGrid(context, filteredList);
      },
    );
  }

  Widget _buildSliverGrid(BuildContext context, List<dynamic> list) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: MediaQuery.of(context).size.width > 600
            ? const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 177 / 253,
              )
            : const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 177 / 253,
              ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCard(furniture: list[index]);
          },
          childCount: list.length,
        ),
      ),
    );
  }

  Widget _buildAiSearchResults(
    BuildContext context,
    WidgetRef ref,
    AiSearchState state,
  ) {
    return switch (state) {
      AiSearchLoading() => const SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Searching with AI...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
        ),
      AiSearchSuccess(results: final results) => MultiSliver(
          children: [
            // Search info banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D3).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 20, color: Color(0xFF2D2D2D)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Found ${results.length} AI-powered results',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ref.read(aiSearchStateProvider.notifier).clearResults();
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2D2D2D),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Results grid
            _buildSliverGrid(context, results),
          ],
        ),
      AiSearchEmpty(query: final _) => SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search query',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(aiSearchStateProvider.notifier).clearResults();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE5D3),
                    foregroundColor: const Color(0xFF2D2D2D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      AiSearchError(message: final message, query: final query) =>
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Search Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (query != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(aiSearchStateProvider.notifier).retry();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE5D3),
                          foregroundColor: const Color(0xFF2D2D2D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(aiSearchStateProvider.notifier).clearResults();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2D2D2D),
                        side: const BorderSide(color: Color(0xFF2D2D2D)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      AiSearchInitial() =>
        const SliverToBoxAdapter(child: SizedBox.shrink()), // Should not reach
    };
  }
}

// Minimal helper to group slivers if MultiSliver is not available
class MultiSliver extends StatelessWidget {
  final List<Widget> children;
  const MultiSliver({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: children);
  }
}
