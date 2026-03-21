import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../common_widgets/feature_banner.dart';
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
          ? SizedBox(
              width: double.infinity,
              height: 226,
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
                      const FeatureBanner(
                        title: 'Featured Collection',
                        subtitle: 'Curated by top local vendors',
                        tagText: 'NEW ARRIVAL',
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        foregroundWidget: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Image(
                            image: AssetImage('assets/bannerSofa.png'),
                            height: 240,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      FeatureBanner(
                        title: 'Smart Planning',
                        subtitle: 'Plan your room within budget before you commit.',
                        tagText: 'SMART PLANNING',
                        tagColor: const Color(0xFFFFD27A),
                        gradientColors: const [
                          Color.fromARGB(255, 92, 207, 245),
                          Color.fromARGB(255, 103, 95, 255),
                        ],
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ctaText: 'Try now',
                        onCtaTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BudgetPlannerPage(),
                            ),
                          );
                        },
                        foregroundWidget: Icon(
                          Icons.savings_outlined,
                          size: 120,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
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
                    top: 18,
                    right: 28,
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
          : const SizedBox.shrink(),
    );
  }
}
