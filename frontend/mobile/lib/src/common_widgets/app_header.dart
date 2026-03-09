import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/profile/presentation/profile_page.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 40),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Use centralized color
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.secondary, // Use centralized color
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
