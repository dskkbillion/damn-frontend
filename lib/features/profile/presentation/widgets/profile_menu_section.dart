import 'package:flutter/material.dart';

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

  const ProfileMenuSection({
    Key? key,
    required this.title,
    required this.menuItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          ...menuItems.map((item) => _buildMenuItem(context, item)).toList(),
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
              color: Colors.grey[600],
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
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
          ],
        ),
      ),
    );
  }
}
