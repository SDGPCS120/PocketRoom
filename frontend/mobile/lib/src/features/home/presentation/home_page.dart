import 'package:flutter/material.dart';
import '../../../common_widgets/app_header.dart';
import '../../../common_widgets/search_bar_widget.dart';
import './widgets/featured_collection_card.dart';
import './widgets/category_icons_row.dart';
import './widgets/section_header.dart';
import './widgets/product_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(),
            SearchBarWidget(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: FeaturedCollectionCard()),
                  SliverToBoxAdapter(child: CategoryIconsRow()),
                  SliverToBoxAdapter(
                    child: SectionHeader(title: "Trending Now"),
                  ),
                  ProductList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
