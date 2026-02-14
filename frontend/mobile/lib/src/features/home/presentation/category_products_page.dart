import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';
import '../../../common_widgets/app_header.dart';
import '../../../common_widgets/search_bar_widget.dart';
import './widgets/category_pills.dart';
import './widgets/section_header.dart';
import './widgets/product_list.dart';

class CategoryProductsPage extends ConsumerWidget {
  const CategoryProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(selectedFurnitureTypeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const SearchBarWidget(),
            const CategoryPills(),
            SectionHeader(title: activeCategory), // Dynamic title
            const Expanded(
              child: CustomScrollView(
                slivers: [
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
