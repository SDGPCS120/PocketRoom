import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/vendor_model.dart';

class VendorHeader extends StatelessWidget {
  final String vendorName;
  final Vendor? vendor;

  const VendorHeader({super.key, required this.vendorName, this.vendor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: colorScheme.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          vendorName,
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (vendor?.imageUrl != null)
              Image.network(
                vendor!.imageUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colorScheme.shadow.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
