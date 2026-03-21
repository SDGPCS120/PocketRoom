import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              color: colorScheme.onSurface,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _PrivacyPolicyContent(),
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _PolicySection(
          heading: '1. Introduction',
          body:
              'PocketRoom values your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use the PocketRoom mobile application.',
        ),
        _PolicySection(
          heading: '2. Information We Collect',
          body: 'We may collect information such as:\n'
              '• Basic account details (name, email)\n'
              '• App usage information\n'
              '• Device information\n'
              '• Preferences and interactions within the app',
        ),
        _PolicySection(
          heading: '3. How We Use Your Information',
          body: 'We use the collected data to:\n'
              '• Improve user experience\n'
              '• Provide personalized features\n'
              '• Maintain app functionality\n'
              '• Communicate important updates',
        ),
        _PolicySection(
          heading: '4. Data Security',
          body:
              'PocketRoom takes appropriate technical and organizational measures to protect your information against unauthorized access or misuse.',
        ),
        _PolicySection(
          heading: '5. Third-Party Services',
          body:
              'The app may use trusted third-party services such as analytics, authentication, or cloud storage providers to support app functionality.',
        ),
        _PolicySection(
          heading: '6. User Control',
          body:
              'Users can manage their account settings, update personal information, or request account deletion through the app.',
        ),
        _PolicySection(
          heading: '7. Updates to This Policy',
          body:
              'This privacy policy may be updated periodically. Any significant changes will be communicated through the app.',
        ),
        _PolicySection(
          heading: '8. Contact Us',
          body:
              'If you have questions regarding this Privacy Policy, please contact us at:\nsupport@pocketroom.lk',
          isLast: true,
        ),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String heading;
  final String body;
  final bool isLast;

  const _PolicySection({
    required this.heading,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
