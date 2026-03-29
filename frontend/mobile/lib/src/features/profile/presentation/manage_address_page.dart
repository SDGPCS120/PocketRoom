import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_client.dart';
import 'widgets/edit_profile/edit_profile_field_label.dart';
import 'widgets/edit_profile/edit_profile_input_field.dart';

class ManageAddressPage extends ConsumerStatefulWidget {
  const ManageAddressPage({super.key});

  @override
  ConsumerState<ManageAddressPage> createState() => _ManageAddressPageState();
}

class _ManageAddressPageState extends ConsumerState<ManageAddressPage> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Sri Lanka');

  bool _loading = true;
  bool _saving = false;
  String? _existingAddressId;

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        '/addresses',
        queryParameters: {'userId': user.uid, 'isDefault': 'true'},
      );

      final List<dynamic> addresses =
          response.data is List ? response.data as List : [];

      if (addresses.isNotEmpty) {
        final addr = addresses.first as Map<String, dynamic>;
        _existingAddressId = addr['id'] as String?;
        _fullNameController.text = addr['fullName'] as String? ?? '';
        _phoneController.text = addr['phoneNumber'] as String? ?? '';
        _addressLine1Controller.text = addr['addressLine1'] as String? ?? '';
        _addressLine2Controller.text = addr['addressLine2'] as String? ?? '';
        _cityController.text = addr['city'] as String? ?? '';
        _districtController.text = addr['district'] as String? ?? '';
        _postalCodeController.text = addr['postalCode'] as String? ?? '';
        _countryController.text = addr['country'] as String? ?? 'Sri Lanka';
      }
    } catch (e) {
      // If fetch fails, start with empty form
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validate() {
    if (_fullNameController.text.trim().isEmpty) return 'Full name is required';
    if (_phoneController.text.trim().isEmpty) return 'Phone number is required';
    if (_addressLine1Controller.text.trim().isEmpty) return 'Address line 1 is required';
    if (_cityController.text.trim().isEmpty) return 'City is required';
    if (_districtController.text.trim().isEmpty) return 'District is required';
    if (_postalCodeController.text.trim().isEmpty) return 'Postal code is required';
    if (_countryController.text.trim().isEmpty) return 'Country is required';
    return null;
  }

  Future<void> _saveAddress() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final apiClient = ref.read(apiClientProvider);

      final payload = {
        'userId': user.uid,
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'addressLine1': _addressLine1Controller.text.trim(),
        if (_addressLine2Controller.text.trim().isNotEmpty)
          'addressLine2': _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
        'isDefault': true,
      };

      if (_existingAddressId != null) {
        // Update existing address
        await apiClient.patch(
          '/addresses/$_existingAddressId',
          data: payload,
        );
      } else {
        // Create new address
        final response = await apiClient.post('/addresses', data: payload);
        final created = response.data as Map<String, dynamic>?;
        _existingAddressId = created?['id'] as String?;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default address saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // return true = address was saved
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, colorScheme),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This address will be used as your default shipping & billing address at checkout.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  const EditProfileFieldLabel('Full Name'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
                    controller: _fullNameController,
                    icon: Icons.person_outline_rounded,
                    hint: 'e.g. Kasun Perera',
                  ),
                  const SizedBox(height: 20),

                  const EditProfileFieldLabel('Phone Number'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: 'e.g. 0771234567',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  const EditProfileFieldLabel('Address Line 1'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
                    controller: _addressLine1Controller,
                    icon: Icons.home_outlined,
                    hint: 'Street, house/apartment number',
                  ),
                  const SizedBox(height: 20),

                  const EditProfileFieldLabel('Address Line 2 (Optional)'),
                  const SizedBox(height: 8),
                  EditProfileInputField(
                    controller: _addressLine2Controller,
                    icon: Icons.add_home_outlined,
                    hint: 'Landmark, additional info',
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const EditProfileFieldLabel('City'),
                            const SizedBox(height: 8),
                            EditProfileInputField(
                              controller: _cityController,
                              icon: Icons.location_city_outlined,
                              hint: 'e.g. Colombo',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const EditProfileFieldLabel('District'),
                            const SizedBox(height: 8),
                            EditProfileInputField(
                              controller: _districtController,
                              icon: Icons.map_outlined,
                              hint: 'e.g. Colombo',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const EditProfileFieldLabel('Postal Code'),
                            const SizedBox(height: 8),
                            EditProfileInputField(
                              controller: _postalCodeController,
                              icon: Icons.markunread_mailbox_outlined,
                              hint: 'e.g. 10350',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const EditProfileFieldLabel('Country'),
                            const SizedBox(height: 8),
                            EditProfileInputField(
                              controller: _countryController,
                              icon: Icons.flag_outlined,
                              hint: 'e.g. Sri Lanka',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                        ),
                      ),
                      child: _saving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              _existingAddressId != null
                                  ? 'Update Address'
                                  : 'Save Address',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 64,
      leading: Center(
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
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
            padding: EdgeInsets.zero,
            icon: const Padding(
              padding: EdgeInsets.only(right: 2),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
            color: colorScheme.onSurface,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text(
        'Shipping Address',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
    );
  }
}
