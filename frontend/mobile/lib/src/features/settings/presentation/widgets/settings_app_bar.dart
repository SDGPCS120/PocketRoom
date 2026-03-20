import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 64, // Provide enough width for margin + button
      leading: Center(
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Padding(
              padding: EdgeInsets.only(right: 2), // nudge icon slightly left visually if needed, because iOS arrow can look off-center
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: const Text('Settings', style: AppTextStyles.appBarTitle),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
