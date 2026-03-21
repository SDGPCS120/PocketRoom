import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onEditProfile;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 24,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 56,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onEditProfile,
                child: Text(
                  name,
                  style: AppTextStyles.profileName(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email.isEmpty ? 'No email on file' : email,
                style: AppTextStyles.profileEmail(context),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onEditProfile,
                child: Text(
                  'Edit Profile',
                  style: AppTextStyles.profileEdit(context),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 28,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.photo_camera_outlined,
              size: 26,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
