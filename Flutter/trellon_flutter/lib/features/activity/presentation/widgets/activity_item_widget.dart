import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/activity_entity.dart';

class ActivityItemWidget extends StatelessWidget {
  final ActivityEntity item;
  final bool isUnread; // Assuming true for UI demo

  const ActivityItemWidget({
    super.key,
    required this.item,
    this.isUnread = true,
  });

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
           bottom: BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread Indicator 3pt blue bar
          Container(
            width: 3,
            height: 36, // Relative to content
            decoration: BoxDecoration(
              color: isUnread ? AppColors.unreadIndicator : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          
          // Icon
          const Icon(Icons.info_outline, size: 24, color: Color(0xFF8993A4)),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(text: '${item.userName} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${item.action} '),
                      TextSpan(
                        text: item.cardTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(item.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), // Footnote
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
