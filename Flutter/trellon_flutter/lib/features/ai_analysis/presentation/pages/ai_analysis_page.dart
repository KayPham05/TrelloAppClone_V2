import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/project_analysis_entity.dart';
import '../cubit/ai_analysis_cubit.dart';
import '../cubit/ai_analysis_state.dart';
import '../widgets/analysis_metric_grid.dart';
import '../widgets/analysis_risk_list.dart';
import '../widgets/analysis_suggestion_list.dart';
import '../widgets/analysis_summary_card.dart';

class AiAnalysisPage extends StatefulWidget {
  final String scopeType;
  final String scopeUId;
  final String title;

  const AiAnalysisPage({
    super.key,
    required this.scopeType,
    required this.scopeUId,
    required this.title,
  });

  @override
  State<AiAnalysisPage> createState() => _AiAnalysisPageState();
}

class _AiAnalysisPageState extends State<AiAnalysisPage> {
  late final AiAnalysisCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator<AiAnalysisCubit>();
    _loadAnalysis();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    final userUId = await serviceLocator<UserLocalDataSource>().getUserId();
    if (userUId == null || userUId.isEmpty) {
      _cubit.showError('Không tìm thấy người dùng hiện tại.');
      return;
    }
    await _cubit.analyze(
      scopeType: widget.scopeType,
      scopeUId: widget.scopeUId,
      userUId: userUId,
    );
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
          actions: [
            IconButton(
              tooltip: 'Tải lại báo cáo',
              icon: const Icon(Icons.refresh),
              onPressed: _loadAnalysis,
            ),
          ],
        ),
        body: BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
          builder: (context, state) {
            if (state is AiAnalysisLoading || state is AiAnalysisInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AiAnalysisError) {
              return _ErrorView(message: state.message, onRetry: _loadAnalysis);
            }
            if (state is AiAnalysisLoaded) {
              return _LoadedAnalysisView(state: state);
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

  const _LoadedAnalysisView({required this.state});

  @override
  Widget build(BuildContext context) {
    final analysis = state.analysis;

    return RefreshIndicator(
      onRefresh: () async {
        final cubit = context.read<AiAnalysisCubit>();
        final userUId = await serviceLocator<UserLocalDataSource>().getUserId();
        if (userUId == null || userUId.isEmpty) {
          cubit.showError('Không tìm thấy người dùng hiện tại.');
          return;
        }
        await cubit.analyze(
          scopeType: analysis.scopeType,
          scopeUId: analysis.scopeUId,
          userUId: userUId,
        );
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          AnalysisSummaryCard(analysis: analysis),
          const SizedBox(height: 18),
          _SectionTitle('Chỉ số chính'),
          const SizedBox(height: 10),
          AnalysisMetricGrid(metrics: analysis.metrics),
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
