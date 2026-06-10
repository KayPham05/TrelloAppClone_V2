import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/project_analysis_entity.dart';

class AnalysisSummaryCard extends StatelessWidget {
  final ProjectAnalysisEntity analysis;

  const AnalysisSummaryCard({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final generatedAt = analysis.generatedAt?.toLocal();
    final generatedAtText = generatedAt == null
        ? 'Chưa rõ thời điểm'
        : DateFormat('dd/MM/yyyy HH:mm').format(generatedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  analysis.title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildHealthBadge(analysis),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            analysis.summary,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _ReportMetaRow(
            generatedAtText: generatedAtText,
            model: analysis.model.isEmpty ? 'Gemini' : analysis.model,
            cached: analysis.cached,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(ProjectAnalysisEntity analysis) {
    final overdue = analysis.metrics.overdueCards;
    final dueSoon = analysis.metrics.dueSoonCards;
    
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    if (overdue > 0) {
      bgColor = Colors.red.withAlpha(26); // ~0.1 opacity
      textColor = Colors.red.shade700;
      label = 'Rủi ro ($overdue)';
      icon = Icons.warning_amber_rounded;
    } else if (dueSoon > 0) {
      bgColor = Colors.orange.withAlpha(26);
      textColor = Colors.orange.shade800;
      label = 'Lưu ý ($dueSoon)';
      icon = Icons.info_outline_rounded;
    } else {
      bgColor = Colors.green.withAlpha(26);
      textColor = Colors.green.shade700;
      label = 'Tốt';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}


class _ReportMetaRow extends StatelessWidget {
  final String generatedAtText;
  final String model;
  final bool cached;

  const _ReportMetaRow({
    required this.generatedAtText,
    required this.model,
    required this.cached,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaLine(icon: Icons.access_time, text: 'Tính đến $generatedAtText'),
          const SizedBox(height: 6),
          _MetaLine(
            icon: Icons.smart_toy_outlined,
            text: cached ? 'Model: $model · bản cache' : 'Model: $model',
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
