import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class EditProfileAvatarCard extends StatelessWidget {
  const EditProfileAvatarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          // Avatar with camera badge overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 56,
                  color: AppColors.textPrimary,
                ),
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Save Photo pill button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: const Text(
              'Save Photo',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
