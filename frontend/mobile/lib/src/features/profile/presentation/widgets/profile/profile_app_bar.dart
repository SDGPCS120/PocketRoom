import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../settings/presentation/settings_page.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Colors.transparent,
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
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Padding(
              padding: EdgeInsets.only(right: 2), // Nudge the icon slightly left
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            color: colorScheme.onSurface,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text('Profile', style: AppTextStyles.appBarTitle(context)),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
