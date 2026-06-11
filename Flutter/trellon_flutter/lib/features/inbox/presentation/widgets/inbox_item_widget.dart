import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/card_status_values.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

class InboxItemWidget extends StatelessWidget {
  final CardEntity item;
  final int index;
  final int totalCount;
  final ValueChanged<bool> onToggleComplete;

  const InboxItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.totalCount,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final status = CardStatusValues.calculate(item.status, item.dueDate);
    final bool isCompleted = CardStatusValues.isCompleted(status);
    final dueStatusColor = CardStatusValues.isOverdue(status)
        ? Colors.red
        : CardStatusValues.isDueSoon(status)
            ? AppColors.warning
            : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: GestureDetector(
          onTap: () {
            onToggleComplete(!isCompleted);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppColors.success : AppColors.outlineVariant,
                width: 2,
              ),
              color: isCompleted ? AppColors.success.withValues(alpha: 0.15) : Colors.transparent,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.success, size: 14)
                : null,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isCompleted ? AppColors.textSecondary : AppColors.onSurface,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: (item.dueDate != null || item.todoItems.isNotEmpty)
            ? Row(
                children: [
                  if (item.dueDate != null) ...[
                    Icon(Icons.schedule, size: 12, color: dueStatusColor),
                    const SizedBox(width: 4),
                    Text(
                      '${item.dueDate!.day}/${item.dueDate!.month}',
                      style: TextStyle(fontSize: 12, color: dueStatusColor),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (item.todoItems.isNotEmpty) ...[
                    const Icon(Icons.check_box_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${item.todoItems.where((e) => e.isCompleted).length}/${item.todoItems.length}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              )
            : null,
        trailing: null,
        onTap: () => _showCardOptions(context),
      ),
    );
  }

  void _showCardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.title, style: const TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.textPrimary),
              title: const Text('Chỉnh sửa ngày giờ', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                // Implement Due Date picker logic integrating with CardCubit
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box, color: AppColors.textPrimary),
              title: const Text('Thêm Todo Item', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                // Implement Adding Todo Item logic integrating with CardCubit
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
