import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/planner_entity.dart';

class PlannerDayRowWidget extends StatelessWidget {
  final PlannerDayEntity day;
  final bool isToday;
  final bool isLast;

  const PlannerDayRowWidget({
    super.key,
    required this.day,
    required this.isToday,
    required this.isLast,
  });

  String _getShortWeekday(int weekday) {
    const days = ['Th 2','Th 3','Th 4','Th 5','Th 6','Th 7','CN'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weekday = _getShortWeekday(day.date.weekday);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date circle
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Text(
                      weekday,
                      style: TextStyle(
                        color: isToday ? AppColors.accent : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? AppColors.accent : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.date.day}',
                        style: TextStyle(
                          color: isToday ? Colors.white : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Tasks or empty state
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (day.hasTask)
                      ...day.taskTitles.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            task,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          ),
                        ),
                      ))
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Chưa lên kế hoạch nào',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Today separator line
        if (isToday)
          Container(height: 1.5, color: AppColors.accent.withValues(alpha: 0.5)),
        if (!isToday && !isLast)
          Container(height: 0.3, margin: const EdgeInsets.only(left: 60), color: AppColors.border.withValues(alpha: 0.3)),
      ],
    );
  }
}
