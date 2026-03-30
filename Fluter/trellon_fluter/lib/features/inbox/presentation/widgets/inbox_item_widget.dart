import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    final bool isFirst = index == 0;
    final bool isLast = index == totalCount - 1;
    final bool isCompleted = item.status == 'Completed';

    BorderRadius radius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(12) : Radius.zero,
      topRight: isFirst ? const Radius.circular(12) : Radius.zero,
      bottomLeft: isLast ? const Radius.circular(12) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: !isLast
            ? const Border(bottom: BorderSide(color: AppColors.border, width: 0.5))
            : null,
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
                color: isCompleted ? AppColors.success : AppColors.textSecondary,
                width: 2,
              ),
              color: isCompleted ? AppColors.success.withOpacity(0.15) : Colors.transparent,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.success, size: 14)
                : null,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            fontSize: 15,
          ),
        ),
        subtitle: (item.dueDate != null || item.todoItems.isNotEmpty)
            ? Row(
                children: [
                  if (item.dueDate != null) ...[
                    const Icon(Icons.schedule, size: 12, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${item.dueDate!.day}/${item.dueDate!.month}',
                      style: const TextStyle(fontSize: 12, color: AppColors.warning),
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
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 16),
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
