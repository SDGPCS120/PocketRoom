import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class EditProfileAvatarCard extends StatelessWidget {
  const EditProfileAvatarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 56,
                  color: colorScheme.onPrimary,
                ),
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.onPrimary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Save Photo pill button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Text(
              'Save Photo',
              style: TextStyle(
                color: colorScheme.onPrimary,
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
