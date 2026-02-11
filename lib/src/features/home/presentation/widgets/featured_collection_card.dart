import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturedCollectionCard extends StatelessWidget {
  const FeaturedCollectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 200, // Fixed height as per design appearance
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Placeholder gradient to mimic the "warm/earthy" tone of the mockup
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCfb088), // Muted brownish/gold top
            Color(0xFF5A4A3A), // Darker brown bottom
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image Placeholder (if we had one)
          // keeping it as a gradient for now as per plan/assets availability
          
          // Text Content
          Positioned(
            left: 24,
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEW ARRIVAL',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF8A3D), // Orange accent
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Featured Collection',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Curated by top local vendors',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
