import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/report_history_item_entity.dart';
import '../../domain/usecases/get_report_by_id_usecase.dart';
import '../cubit/ai_analysis_cubit.dart';
import '../cubit/ai_analysis_state.dart';
import 'ai_analysis_page.dart';

class ReportHistoryPage extends StatefulWidget {
  final String scopeType;
  final String scopeUId;
  final String title;

  const ReportHistoryPage({
    super.key,
    required this.scopeType,
    required this.scopeUId,
    required this.title,
  });

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  late final AiAnalysisCubit _cubit;
  String? _openingReportUId;

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator<AiAnalysisCubit>();
    _loadHistory();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadHistory({int page = 1}) {
    return _cubit.loadHistory(
      scopeType: widget.scopeType,
      scopeUId: widget.scopeUId,
      page: page,
      pageSize: 5,
    );
  }

  Future<void> _openReport(ReportHistoryItemEntity item) async {
    setState(() => _openingReportUId = item.reportUId);
    try {
      final report = await serviceLocator<GetReportByIdUseCase>()(
        reportUId: item.reportUId,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AiAnalysisPage(
            scopeType: report.scopeType,
            scopeUId: report.scopeUId,
            title: item.title,
            initialAnalysis: report,
            readOnly: true,
          ),
        ),
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
        setState(() => _openingReportUId = null);
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
            'Lịch sử báo cáo',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800),
          ),
        ),
        body: BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
          builder: (context, state) {
            if (state is AiAnalysisLoading || state is AiAnalysisInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AiAnalysisError) {
              return _HistoryErrorView(
                message: state.message,
                onRetry: () => _loadHistory(),
              );
            }
            if (state is AiAnalysisHistoryLoaded) {
              if (state.items.isEmpty) {
                return const Center(child: Text('Chưa có báo cáo cũ.'));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  ...state.items.map(
                    (item) => _HistoryItemTile(
                      item: item,
                      isOpening: _openingReportUId == item.reportUId,
                      onTap: () => _openReport(item),
                    ),
                  ),
                  if (state.hasMore) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _loadHistory(page: state.page + 1),
                      child: const Text('Tải thêm'),
                    ),
                  ],
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  final ReportHistoryItemEntity item;
  final bool isOpening;
  final VoidCallback onTap;

  const _HistoryItemTile({
    required this.item,
    required this.isOpening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: isOpening ? null : onTap,
        title: Text(
          item.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${item.model} • ${_formatDate(item.generatedAt)}',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        trailing: isOpening
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _ProgressBadge(progress: item.overallProgress),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int progress;

  const _ProgressBadge({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$progress%',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _HistoryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryErrorView({required this.message, required this.onRetry});

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

String _formatDate(DateTime? value) {
  if (value == null) return 'không xác định';
  final local = value.toLocal();
  String two(int input) => input.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}
