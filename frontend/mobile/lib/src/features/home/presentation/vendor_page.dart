import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../data/providers.dart';
import 'widgets/vendor_header.dart';
import 'widgets/vendor_details.dart';
import 'widgets/vendor_product_grid.dart';

class VendorPage extends ConsumerWidget {
  final String vendorName;

  const VendorPage({super.key, required this.vendorName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorByNameProvider(vendorName));
    final productsAsync = ref.watch(vendorFurnitureProvider(vendorName));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          vendorAsync.when(
            data: (vendor) => VendorHeader(vendorName: vendorName, vendor: vendor),
            loading: () => SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(title: Text(vendorName)),
            ),
            error: (_, __) => SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(title: Text(vendorName)),
            ),
          ),

          // ── Vendor Info ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: vendorAsync.when(
              data: (vendor) => VendorDetails(vendorName: vendorName, vendor: vendor),
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (e, __) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Error loading vendor info: $e'),
              ),
            ),
          ),

          // ── Products Grid ─────────────────────────────────────────────────
          productsAsync.when(
            data: (products) => VendorProductGrid(products: products),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, __) => SliverToBoxAdapter(
              child: Center(child: Text('Error loading products: $e')),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
