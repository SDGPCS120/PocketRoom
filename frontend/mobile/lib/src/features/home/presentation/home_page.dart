import 'package:flutter/material.dart';
import '../../../common_widgets/app_header.dart';
import '../../../common_widgets/search_bar_widget.dart';
import './widgets/featured_collection_card.dart';
import './widgets/category_icons_row.dart';
import './widgets/section_header.dart';
import 'widgets/product_list.dart';
import 'widgets/carousel_countdown_timer.dart';
import '../data/providers.dart';

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
            if (MediaQuery.of(context).size.width <= 600)
              const SearchBarWidget(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: FeaturedCollectionCard()),
                  const SliverToBoxAdapter(child: CategoryIconsRow()),
                  
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: "Trending Now", showSort: false),
                  ),
                  const ProductList(isHorizontal: true, provider: trendingFurnitureProvider),
                  
                  const SliverToBoxAdapter(
                    child: SectionHeader(title: "Budget Friendly", showSort: false),
                  ),
                  const ProductList(isHorizontal: true, provider: budgetFriendlyFurnitureProvider),

                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: "Limited Time Offers",
                      showSort: false,
                      trailing: CarouselCountdownTimer(
                        endTime: DateTime.now().add(const Duration(hours: 12, minutes: 45)),
                      ),
                    ),
                  ),
                  const ProductList(isHorizontal: true, provider: limitedTimeFurnitureProvider),
                  
                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
