import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/project_analysis_entity.dart';
import '../../domain/usecases/save_current_report_usecase.dart';
import '../cubit/ai_analysis_cubit.dart';
import '../cubit/ai_analysis_state.dart';
import 'report_history_page.dart';
import '../widgets/analysis_metric_grid.dart';
import '../widgets/analysis_risk_list.dart';
import '../widgets/analysis_status_chart.dart';
import '../widgets/analysis_suggestion_list.dart';
import '../widgets/analysis_summary_card.dart';

class AiAnalysisPage extends StatefulWidget {
  final String scopeType;
  final String scopeUId;
  final String title;
  final ProjectAnalysisEntity? initialAnalysis;
  final bool readOnly;

  const AiAnalysisPage({
    super.key,
    required this.scopeType,
    required this.scopeUId,
    required this.title,
    this.initialAnalysis,
    this.readOnly = false,
  });

  @override
  State<AiAnalysisPage> createState() => _AiAnalysisPageState();
}

class _AiAnalysisPageState extends State<AiAnalysisPage> {
  late final AiAnalysisCubit _cubit;
  bool _savingReport = false;

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator<AiAnalysisCubit>();
    final initialAnalysis = widget.initialAnalysis;
    if (initialAnalysis != null) {
      _cubit.showLoaded(initialAnalysis);
    } else {
      _loadAnalysis();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadAnalysis({bool forceRefresh = false}) async {
    if (widget.readOnly) {
      return;
    }
    await _cubit.analyze(
      scopeType: widget.scopeType,
      scopeUId: widget.scopeUId,
      forceRefresh: forceRefresh,
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportHistoryPage(
          scopeType: widget.scopeType,
          scopeUId: widget.scopeUId,
          title: widget.title,
        ),
      ),
    );
  }

  Future<void> _saveCurrentReport(ProjectAnalysisEntity analysis) async {
    if (_savingReport || widget.readOnly) {
      return;
    }
    setState(() => _savingReport = true);
    try {
      await serviceLocator<SaveCurrentReportUseCase>()(
        scopeType: widget.scopeType,
        scopeUId: widget.scopeUId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu báo cáo vào lịch sử.')),
      );
    } catch (error) {
      if (!mounted) return;
      final raw = error.toString();
      final message = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _savingReport = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            'Báo cáo AI',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800),
          ),
          actions: widget.readOnly
              ? const []
              : [
                  BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                    builder: (context, state) {
                      final analysis = state is AiAnalysisLoaded ? state.analysis : null;
                      final isGemini = analysis?.isGeminiSuccess ?? false;
                      final canSave = !_savingReport && isGemini;
                      return IconButton(
                        tooltip: isGemini
                            ? 'Lưu báo cáo'
                            : 'Không thể lưu: báo cáo dùng dữ liệu dự phòng (Gemini không khả dụng)',
                        icon: _savingReport
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                isGemini
                                    ? Icons.save_outlined
                                    : Icons.cloud_off_outlined,
                                color: isGemini ? null : Colors.grey,
                              ),
                        onPressed: canSave
                            ? () => _saveCurrentReport(analysis!)
                            : null,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Lịch sử báo cáo',
                    icon: const Icon(Icons.history),
                    onPressed: _openHistory,
                  ),
                  IconButton(
                    tooltip: 'Kiểm tra dữ liệu mới',
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      _loadAnalysis(forceRefresh: true);
                    },
                  ),
                ],
        ),
        body: BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
          builder: (context, state) {
            if (state is AiAnalysisLoading || state is AiAnalysisInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AiAnalysisError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  _loadAnalysis(forceRefresh: true);
                },
              );
            }
            if (state is AiAnalysisLoaded) {
              return _LoadedAnalysisView(
                state: state,
                readOnly: widget.readOnly,
                onRefresh: () => _loadAnalysis(forceRefresh: true),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _LoadedAnalysisView extends StatelessWidget {
  final AiAnalysisLoaded state;
  final bool readOnly;
  final Future<void> Function() onRefresh;

  const _LoadedAnalysisView({
    required this.state,
    required this.readOnly,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = state.analysis;

    final content = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (readOnly) ...[
          _HistoryBanner(generatedAt: analysis.generatedAt),
          const SizedBox(height: 12),
        ],
        if (!readOnly && !analysis.isGeminiSuccess) ...[
          _FallbackBanner(),
          const SizedBox(height: 12),
        ],
        AnalysisSummaryCard(analysis: analysis),
        const SizedBox(height: 18),
        _SectionTitle('Chỉ số chính'),
        const SizedBox(height: 10),
        AnalysisMetricGrid(metrics: analysis.metrics),
        const SizedBox(height: 18),
        _SectionTitle('Trạng thái thẻ'),
        const SizedBox(height: 10),
        AnalysisStatusChart(metrics: analysis.metrics),
        const SizedBox(height: 18),
        _SectionTitle('Rủi ro'),
        const SizedBox(height: 10),
        AnalysisRiskList(risks: analysis.risks),
        const SizedBox(height: 18),
        _SectionTitle('Đề xuất hành động'),
        const SizedBox(height: 10),
        AnalysisSuggestionList(suggestions: analysis.suggestions),
        if (analysis.breakdown.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionTitle('Tiến độ theo nhóm'),
          const SizedBox(height: 10),
          ...analysis.breakdown.map((item) => _BreakdownTile(item)),
        ],
        if (analysis.inferredMilestones.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionTitle('Mốc suy luận'),
          const SizedBox(height: 10),
          ...analysis.inferredMilestones.map((item) => _MilestoneTile(item)),
        ],
      ],
    );

    if (readOnly) {
      return content;
    }

    return RefreshIndicator(onRefresh: onRefresh, child: content);
  }
}

class _HistoryBanner extends StatelessWidget {
  final DateTime? generatedAt;

  const _HistoryBanner({required this.generatedAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Đang xem báo cáo ngày ${_formatDate(generatedAt)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'không xác định';
  final local = value.toLocal();
  String two(int input) => input.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}

class _FallbackBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Gemini không khả dụng — báo cáo này dùng dữ liệu dự phòng và không thể lưu vào lịch sử.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final ProjectAnalysisBreakdownEntity item;

  const _BreakdownTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${item.progress}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: item.progress / 100),
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.note,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final ProjectAnalysisMilestoneEntity item;

  const _MilestoneTile(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag_outlined, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  item.note,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.red),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
