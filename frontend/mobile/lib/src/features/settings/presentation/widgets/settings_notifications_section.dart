import 'package:flutter/material.dart';
import 'settings_section_card.dart';
import 'settings_section_divider.dart';
import 'settings_section_toggle_item.dart';

class SettingsNotificationsSection extends StatelessWidget {
  final bool pushNotifications;
  final bool orderUpdates;
  final ValueChanged<bool> onPushNotificationsChanged;
  final ValueChanged<bool> onOrderUpdatesChanged;

  const SettingsNotificationsSection({
    super.key,
    required this.pushNotifications,
    required this.orderUpdates,
    required this.onPushNotificationsChanged,
    required this.onOrderUpdatesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Notifications',
      items: [
        SettingsSectionToggleItem(
          icon: Icons.notifications_active_outlined,
          label: 'Push Notifications',
          value: pushNotifications,
          onChanged: onPushNotificationsChanged,
        ),
        const SettingsSectionDivider(),
        SettingsSectionToggleItem(
          icon: Icons.local_shipping_outlined,
          label: 'Order Updates',
          value: orderUpdates,
          onChanged: onOrderUpdatesChanged,
        ),
      ],
    );
  }
}
