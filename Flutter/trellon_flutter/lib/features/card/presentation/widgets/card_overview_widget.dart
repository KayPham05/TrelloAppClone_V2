import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import '../../../../core/constants/app_colors.dart';

class CardOverviewWidget extends StatelessWidget {
  final CardEntity card;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleComplete;

  const CardOverviewWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = card.status == 'Completed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest, // Pure white for popping forward
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.04), // Ambient shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            if (card.backgroundUrl != null && card.backgroundUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    card.backgroundUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onToggleComplete(!isCompleted),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? const Color(0xFF1D4ED8) : AppColors.outlineVariant,
                        width: 2,
                      ),
                      color: isCompleted ? const Color(0xFF1D4ED8) : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    card.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (card.dueDate != null || card.todoItems.isNotEmpty)
                  Row(
                    children: [
                       if (card.todoItems.isNotEmpty) ...[
                          const Icon(Icons.check_box_outlined, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${card.todoItems.where((e) => e.isCompleted).length}/${card.todoItems.length}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                          if (card.dueDate != null) const SizedBox(width: 10),
                       ],
                       if (card.dueDate != null) ...[
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${card.dueDate!.day}/${card.dueDate!.month}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                       ],
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
