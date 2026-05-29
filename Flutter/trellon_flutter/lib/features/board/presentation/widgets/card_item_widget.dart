import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../card/domain/entities/card_entity.dart';

class CardItemWidget extends StatelessWidget {
  final CardEntity card;

  const CardItemWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCardDetail(context, card),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
            if (card.description != null) ...[
              const SizedBox(height: 4),
              Text(
                card.description!,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (card.dueDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule, color: AppColors.warning, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(card.dueDate!),
                    style: const TextStyle(color: AppColors.warning, fontSize: 11),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCardDetail(BuildContext context, CardEntity card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(card.title, style: const TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            if (card.description != null) ...[
              const SizedBox(height: 12),
              Text(card.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _statusChip(card.status),
                if (card.dueDate != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: AppColors.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(_formatDate(card.dueDate!), style: const TextStyle(color: AppColors.warning, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'In Progress': color = AppColors.warning; break;
      case 'Done': color = AppColors.success; break;
      case 'Review': color = AppColors.accent; break;
      default: color = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
