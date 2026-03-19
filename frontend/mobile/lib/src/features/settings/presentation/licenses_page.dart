import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Licenses',
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
        child: _LicensesContent(),
      ),
    );
  }
}

class _LicensesContent extends StatelessWidget {
  const _LicensesContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Open Source Licenses',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'PocketRoom uses several open-source libraries to deliver a smooth and reliable experience. Below are some of the libraries used in this application.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        SizedBox(height: 20),
        _LicenseItem(
          name: '1. Flutter',
          license: 'BSD 3-Clause License',
          description:
              'Flutter is used as the core framework for building the PocketRoom mobile application.',
        ),
        _LicenseItem(
          name: '2. Firebase',
          license: 'Apache License 2.0',
          description:
              'Firebase services are used for authentication, cloud storage, and backend integrations.',
        ),
        _LicenseItem(
          name: '3. Provider',
          license: 'MIT License',
          description:
              'Provider is used for state management within the application.',
        ),
        _LicenseItem(
          name: '4. HTTP',
          license: 'BSD License',
          description:
              'The HTTP package is used for making API requests and handling network communication.',
        ),
        _LicenseItem(
          name: '5. URL Launcher',
          license: 'BSD License',
          description:
              'URL Launcher is used to open external links such as support pages and websites.',
        ),
        _LicenseItem(
          name: '6. Material Icons',
          license: 'Apache License 2.0',
          description:
              'Material icons are used for the interface icons across the application.',
        ),
        _LicenseItem(
          name: '7. Other Dependencies',
          license: '',
          description:
              'Additional open-source packages may be used to improve performance, security, and functionality of the PocketRoom application.',
          isLast: true,
        ),
      ],
    );
  }
}

class _LicenseItem extends StatelessWidget {
  final String name;
  final String license;
  final String description;
  final bool isLast;

  const _LicenseItem({
    required this.name,
    required this.license,
    required this.description,
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
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (license.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'License: $license',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            description,
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
