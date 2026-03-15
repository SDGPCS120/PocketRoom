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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            if (MediaQuery.of(context).size.width <= 600)
              const SearchBarWidget(),
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
