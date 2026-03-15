import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturedCollectionCard extends StatefulWidget {
  const FeaturedCollectionCard({super.key});

  @override
  State<FeaturedCollectionCard> createState() => _FeaturedCollectionCardState();
}

class _FeaturedCollectionCardState extends State<FeaturedCollectionCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    // Use AnimatedSize for smooth resizing when closing
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isVisible
          ? Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Sofa Image on the right
                    Positioned(
                      right: -30,
                      bottom: -20,
                      child: Image.asset(
                        'assets/bannerSofa.png',
                        height: 240,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Gradient overlay to fade the sofa into the background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFF5A4A3A), // Fully solid on left
                              const Color(0xFF5A4A3A).withValues(alpha: 0.8), // Solid mid left
                              const Color(0xFF5A4A3A).withValues(alpha: 0.3), // Far fade
                              Colors.transparent, // Only clear at the very right
                            ],
                            stops: const [0.0, 0.4, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),
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
                  
                  // Close Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        setState(() {
                          _isVisible = false;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Tight fit
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.1),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              ),
            )
          : const SizedBox.shrink(), // Takes up zero space when hidden
    );
  }
}
