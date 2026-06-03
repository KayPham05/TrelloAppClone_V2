import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/project_analysis_entity.dart';

class AnalysisMetricGrid extends StatelessWidget {
  final ProjectAnalysisMetricsEntity metrics;

  const AnalysisMetricGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MetricItem('Thẻ', metrics.totalCards, Icons.dashboard_outlined),
      _MetricItem('Hoàn tất', metrics.doneCards, Icons.check_circle_outline),
      _MetricItem('Quá hạn', metrics.overdueCards, Icons.schedule_outlined),
      _MetricItem('Checklist', metrics.doneTodoItems, Icons.task_alt),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.value.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricItem {
  final String label;
  final int value;
  final IconData icon;

  const _MetricItem(this.label, this.value, this.icon);
}
