import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketroom/src/features/auth/presentation/get_started_page.dart';
import 'package:pocketroom/src/features/home/presentation/home_page.dart';
import 'package:pocketroom/src/features/cart/presentation/cart_page.dart';
import 'package:pocketroom/src/features/favorites/presentation/favorites_page.dart';
import 'package:pocketroom/src/features/profile/presentation/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    final user = FirebaseAuth.instance.currentUser;
    final isSignedIn = user != null && !user.isAnonymous;

    if (index == 3 && !isSignedIn) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const GetStartedPage()));
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              HomePage(onProfileTap: () => _onItemTapped(3)),
              const CartPage(),
              const FavoritesPage(),
              const ProfilePage(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingBottomBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBottomBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _FloatingBottomBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      heightFactor: 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: colorScheme.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NavBarItem(
              icon: Icons.home_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onItemSelected(0),
            ),
            const SizedBox(width: 8),
            _NavBarItem(
              icon: Icons.shopping_cart_rounded,
              isSelected: selectedIndex == 1,
              onTap: () => onItemSelected(1),
            ),
            const SizedBox(width: 8),
            _NavBarItem(
              icon: Icons.favorite_rounded,
              isSelected: selectedIndex == 2,
              onTap: () => onItemSelected(2),
            ),
            const SizedBox(width: 8),
            _NavBarItem(
              icon: Icons.person_rounded,
              isSelected: selectedIndex == 3,
              onTap: () => onItemSelected(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }
}
