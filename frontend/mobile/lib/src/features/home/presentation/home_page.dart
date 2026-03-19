import 'package:flutter/material.dart';
import '../../../common_widgets/app_header.dart';
import '../../../common_widgets/search_bar_widget.dart';
import './widgets/category_pills.dart';
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
            const SearchBarWidget(),
            const CategoryPills(),
            const SectionHeader(),
            Expanded(child: ProductList()),
          ],
        ),
      ),
    );
  }
}
