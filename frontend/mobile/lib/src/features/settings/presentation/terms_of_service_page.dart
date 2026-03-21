import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Section(
          heading: '1. Acceptance of Terms',
          body:
              'By accessing or using the PocketRoom mobile application, you agree to be bound by these Terms of Service. If you do not agree with these terms, please do not use the application.',
        ),
        _Section(
          heading: '2. Use of the Application',
          body:
              'Users agree to use PocketRoom only for lawful purposes and in accordance with these terms. Any misuse of the platform may result in suspension or termination of access.',
        ),
        _Section(
          heading: '3. User Accounts',
          body:
              'Users are responsible for maintaining the confidentiality of their account information and for all activities that occur under their account.',
        ),
        _Section(
          heading: '4. Content and Information',
          body:
              'PocketRoom may display product information, recommendations, or other content. While we strive for accuracy, we do not guarantee that all information is complete or up to date.',
        ),
        _Section(
          heading: '5. Third-Party Services',
          body:
              'The application may integrate or link to third-party services. PocketRoom is not responsible for the content or practices of these external services.',
        ),
        _Section(
          heading: '6. Limitation of Liability',
          body:
              'PocketRoom will not be liable for any indirect, incidental, or consequential damages arising from the use of the application.',
        ),
        _Section(
          heading: '7. Changes to Terms',
          body:
              'PocketRoom reserves the right to update or modify these Terms of Service at any time. Continued use of the application after changes are made constitutes acceptance of the updated terms.',
        ),
        _Section(
          heading: '8. Contact Information',
          body:
              'If you have questions regarding these Terms of Service, please contact us at:\nsupport@pocketroom.lk',
          isLast: true,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String heading;
  final String body;
  final bool isLast;

  const _Section({
    required this.heading,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
