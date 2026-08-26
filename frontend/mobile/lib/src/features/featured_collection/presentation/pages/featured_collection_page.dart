import 'package:flutter/material.dart';
import '../../../../common_widgets/app_header.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../home/presentation/widgets/product_list.dart';
import '../providers/featured_collection_provider.dart';

class FeaturedCollectionPage extends StatelessWidget {
  const FeaturedCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checkout our new featured collection',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Carefully curated pieces to elevate your living space with style and comfort.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Featured Picks',
                      showSort: false,
                    ),
                  ),
                  ProductList(
                    provider: featuredCollectionProvider,
                    isHorizontal: false, // Grid view
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
