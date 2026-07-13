import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_colors.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';

class MenuItem {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Widget? trailing;

  const MenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.trailing,
  });
}

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<MenuItem> menuItems;
  final double bottomPadding;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.menuItems,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(top: 16),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...menuItems.map((item) => _buildMenuItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            item.trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
          ],
        ),
      ),
    );
  }
}
