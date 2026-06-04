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
    final totalCards = analysis.metrics.totalCards;
    final doneCards = analysis.metrics.doneCards;

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
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: analysis.overallProgress / 100,
                      strokeWidth: 8,
                      backgroundColor: AppColors.surfaceContainerLow,
                      color: AppColors.primary,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${analysis.overallProgress}%',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'thẻ',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tiến độ theo thẻ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$doneCards/$totalCards thẻ hoàn tất',
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
