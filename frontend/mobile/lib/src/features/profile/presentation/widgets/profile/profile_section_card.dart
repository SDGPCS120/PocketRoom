import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }
}
