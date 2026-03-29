import 'package:flutter/material.dart';
import 'section_item.dart';
import 'profile_section_card.dart';
import 'profile_section_divider.dart';

class ProfilePersonalInfoSection extends StatelessWidget {
  final String role;
  final String email;
  final String phone;
  final String address;
  final VoidCallback onEditProfile;
  final VoidCallback onManageAddress;

  const ProfilePersonalInfoSection({
    super.key,
    required this.role,
    required this.email,
    required this.phone,
    required this.address,
    required this.onEditProfile,
    required this.onManageAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Personal Information',
      items: [
        SectionItem(
          icon: Icons.badge_outlined,
          label: 'Role',
          value: role,
          onTap: () {},
        ),
        const ProfileSectionDivider(),
        SectionItem(
          icon: Icons.email_outlined,
          label: 'Email',
          value: email.isEmpty ? 'Add email' : email,
          onTap: onEditProfile,
        ),
        const ProfileSectionDivider(),
        SectionItem(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: phone.isEmpty ? 'Add phone number' : phone,
          onTap: onEditProfile,
        ),
        const ProfileSectionDivider(),
        SectionItem(
          icon: Icons.home_outlined,
          label: 'Shipping Address',
          value: address.isEmpty ? 'Add address' : address,
          onTap: onManageAddress,
        ),
      ],
    );
  }
}
