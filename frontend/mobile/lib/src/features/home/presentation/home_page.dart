import 'package:flutter/material.dart';
import '../../../common_widgets/app_header.dart';
import '../../../common_widgets/search_bar_widget.dart';
import './widgets/featured_collection_card.dart';
import './widgets/category_icons_row.dart';
import './widgets/section_header.dart';
import './widgets/product_list.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomePage({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(onProfileTap: onProfileTap),
            const SearchBarWidget(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: FeaturedCollectionCard()),
                  const SliverToBoxAdapter(child: CategoryIconsRow()),
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: "Trending Now"),
                  ),
                  const ProductList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

