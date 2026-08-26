import 'package:flutter/material.dart';
import '../../../common_widgets/app_header.dart';
import '../../home/presentation/widgets/product_list.dart';
import 'providers/featured_collection_provider.dart';
import 'widgets/featured_collection_header.dart';

class FeaturedCollectionPage extends StatelessWidget {
  const FeaturedCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: FeaturedCollectionHeader(),
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
