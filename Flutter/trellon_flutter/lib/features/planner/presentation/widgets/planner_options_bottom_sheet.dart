import 'package:flutter/material.dart';

class PlannerOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onJumpToToday;
  final VoidCallback onRefresh;

  const PlannerOptionsBottomSheet({
    super.key,
    required this.onJumpToToday,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tuỳ chọn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF050505),
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            context: context,
            icon: Icons.today,
            title: 'Về Hôm nay',
            onTap: () {
              Navigator.pop(context);
              onJumpToToday();
            },
          ),
          _buildOptionItem(
            context: context,
            icon: Icons.refresh,
            title: 'Làm mới',
            onTap: () {
              Navigator.pop(context);
              onRefresh();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF050505), size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF050505),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
