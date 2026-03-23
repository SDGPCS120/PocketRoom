import 'package:flutter/material.dart';
import 'package:pocketroom/src/features/cart/presentation/cart_page.dart';
import 'section_item.dart';
import 'profile_section_card.dart';
import 'profile_section_divider.dart';

class ProfileActivitySection extends StatelessWidget {
  const ProfileActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'My Activity',
      items: [
        SectionItem(
          icon: Icons.favorite_border_rounded,
          label: 'Wishlist',
          onTap: () {},
        ),
        const ProfileSectionDivider(),
        SectionItem(
          icon: Icons.shopping_cart_outlined,
          label: 'My Orders',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
        ),
        const ProfileSectionDivider(),
        SectionItem(
          icon: Icons.bookmark_border_rounded,
          label: 'Reviews & Ratings',
          onTap: () {},
        ),
      ],
    );
  }
}
