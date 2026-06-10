import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/project_analysis_entity.dart';

class AnalysisStatusChart extends StatelessWidget {
  final ProjectAnalysisMetricsEntity metrics;

  const AnalysisStatusChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final segments = _segments(metrics);
    final total = math.max(
      metrics.totalCards,
      segments.fold<int>(0, (sum, item) => sum + item.count),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: total == 0
          ? Text(
              'Chưa có thẻ để trực quan hóa trạng thái.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 104,
                      height: 104,
                      child: CustomPaint(
                        painter: _DonutChartPainter(segments),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${metrics.doneCards}/$total',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'hoàn tất',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phân bố theo Card.Status',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...segments.map((item) => _LegendItem(item)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...segments.map(
                  (item) => _StatusBar(segment: item, total: total),
                ),
              ],
            ),
    );
  }

  List<_StatusSegment> _segments(ProjectAnalysisMetricsEntity metrics) {
    final distribution = metrics.statusDistribution;
    final todo = distribution['todo'] ?? metrics.todoCards;
    final inProgress = distribution['inProgress'] ?? metrics.inProgressCards;
    final completed = distribution['completed'] ?? metrics.doneCards;
    final other = distribution['other'] ?? metrics.otherCards;

    return [
      _StatusSegment('Chưa làm', todo, AppColors.textSecondary),
      _StatusSegment('Đang làm', inProgress, AppColors.warning),
      _StatusSegment('Hoàn thành', completed, AppColors.success),
      if (other > 0) _StatusSegment('Khác', other, AppColors.labelPurple),
    ];
  }
}

class _StatusSegment {
  final String label;
  final int count;
  final Color color;

  const _StatusSegment(this.label, this.count, this.color);
}

class _LegendItem extends StatelessWidget {
  final _StatusSegment item;

  const _LegendItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            item.count.toString(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final _StatusSegment segment;
  final int total;

  const _StatusBar({required this.segment, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((segment.count / total) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  segment.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: total == 0 ? 0 : segment.count / total,
              color: segment.color,
              backgroundColor: AppColors.surfaceContainerLow,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_StatusSegment> segments;

  const _DonutChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, item) => sum + item.count);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 6);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.butt;

    paint.color = AppColors.surfaceContainerLow;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);

    if (total == 0) return;

    var start = -math.pi / 2;
    for (final segment in segments.where((item) => item.count > 0)) {
      final sweep = (segment.count / total) * math.pi * 2;
      paint.color = segment.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
