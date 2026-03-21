import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common_widgets/glass_container.dart';
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: PageView(
                      clipBehavior: Clip.antiAlias,
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
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: isActive ? 24 : 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: isActive ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ] : null,
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GlassContainer(
                      padding: EdgeInsets.zero,
                      borderRadius: 100,
                      blur: 8,
                      opacity: 0.1,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 14),
                          onPressed: () {
                            setState(() {
                              _isVisible = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCfb088),
            Color(0xFF5A4A3A),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: GlassContainer(
          borderRadius: 24,
          blur: 10,
          opacity: 0.1,
          padding: EdgeInsets.zero,
          border: Border.all(color: Colors.white.withOpacity(0.15)),
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
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF544131).withOpacity(0.6),
                        const Color(0xFF544131).withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A3D).withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEW ARRIVAL',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF8A3D),
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 200,
                      child: Text(
                        'Featured Collection',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Curated by top local vendors',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: GlassContainer(
          borderRadius: 24,
          blur: 10,
          opacity: 0.1,
          padding: EdgeInsets.zero,
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: 10,
                child: Icon(
                  Icons.savings_outlined,
                  size: 140,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SMART PLANNING',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFFD27A),
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: Text(
                        'Try out our budgeting feature',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Plan your room within budget.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BudgetPlannerPage(),
                          ),
                        );
                      },
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        borderRadius: 12,
                        blur: 15,
                        opacity: 0.15,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        child: Text(
                          'Try now',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }





}

