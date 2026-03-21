import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../budget/ui/budget_planner_page.dart';

class FeaturedCollectionCard extends StatefulWidget {
  const FeaturedCollectionCard({super.key});

  @override
  State<FeaturedCollectionCard> createState() => _FeaturedCollectionCardState();
}

class _FeaturedCollectionCardState extends State<FeaturedCollectionCard> {
  bool _isVisible = true;
  PageController? _pageController;
  Timer? _autoSwitchTimer;
  int _currentPage = 0;

  static const _switchDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSwitchTimer();
  }

  @override
  void dispose() {
    _autoSwitchTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _startAutoSwitchTimer() {
    _autoSwitchTimer?.cancel();
    _autoSwitchTimer = Timer.periodic(_switchDuration, (_) {
      final pageController = _pageController;
      if (!mounted || !_isVisible || pageController == null || !pageController.hasClients) {
        return;
      }

      final nextPage = (_currentPage + 1) % 2;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _pageController ??= PageController();

    // Use AnimatedSize for smooth resizing when closing
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isVisible
          ? Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              height: MediaQuery.of(context).size.width > 900 ? 300 : 226, 
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController!,
                    onPageChanged: (index) {
                      if (!mounted) return;
                      setState(() {
                        _currentPage = index;
                      });
                      _startAutoSwitchTimer();
                    },
                    children: [
                      _buildFeaturedCard(),
                      _buildBudgetingCard(context),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: isActive ? 20 : 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
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
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.12),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(), // Takes up zero space when hidden
    );
  }

  Widget _buildFeaturedCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCfb088),
            Color(0xFF5A4A3A),
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
            Positioned(
              right: MediaQuery.of(context).size.width > 900 ? 40 : -30,
              bottom: MediaQuery.of(context).size.width > 900 ? 0 : -20,
              child: Image.asset(
                'assets/bannerSofa.png',
                height: MediaQuery.of(context).size.width > 900 ? 320 : 240,
                fit: BoxFit.contain,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF5A4A3A),
                      const Color(0xFF5A4A3A).withValues(alpha: 0.8),
                      const Color(0xFF5A4A3A).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 120,
              top: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEW ARRIVAL',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF8A3D),
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
      ),
    );
  }

  Widget _buildBudgetingCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 92, 207, 245),
            Color.fromARGB(255, 103, 95, 255),
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
            Positioned(
              right: -10,
              top: 22,
              child: Icon(
                Icons.savings_outlined,
                size: 120,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'SMART PLANNING',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFFD27A),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try out our budgeting feature',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plan your room within budget before you commit.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BudgetPlannerPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD27A),
                        foregroundColor: const Color(0xFF183328),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Try now',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
