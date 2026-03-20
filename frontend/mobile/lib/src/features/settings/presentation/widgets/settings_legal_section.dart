import 'package:flutter/material.dart';
import '../../../profile/presentation/widgets/profile/section_item.dart';
import '../licenses_page.dart';
import '../privacy_policy_page.dart';
import '../terms_of_service_page.dart';
import 'settings_section_card.dart';
import 'settings_section_divider.dart';

class SettingsLegalSection extends StatelessWidget {
  const SettingsLegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Legal',
      items: [
        SectionItem(
          icon: Icons.policy_outlined,
          label: 'Privacy Policy',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
        ),
        const SettingsSectionDivider(),
        SectionItem(
          icon: Icons.description_outlined,
          label: 'Terms of Service',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const TermsOfServicePage())),
        ),
        const SettingsSectionDivider(),
        SectionItem(
          icon: Icons.gavel_outlined,
          label: 'Licenses',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LicensesPage())),
        ),
      ],
    );
  }
}
