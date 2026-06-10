import 'package:equatable/equatable.dart';

import '../../domain/entities/project_analysis_entity.dart';
import '../../domain/entities/report_history_item_entity.dart';

abstract class AiAnalysisState extends Equatable {
  const AiAnalysisState();

  @override
  List<Object?> get props => [];
}

class AiAnalysisInitial extends AiAnalysisState {
  const AiAnalysisInitial();
}

class AiAnalysisLoading extends AiAnalysisState {
  const AiAnalysisLoading();
}

class AiAnalysisLoaded extends AiAnalysisState {
  final ProjectAnalysisEntity analysis;

  const AiAnalysisLoaded(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class AiAnalysisHistoryLoaded extends AiAnalysisState {
  final List<ReportHistoryItemEntity> items;
  final int page;
  final bool hasMore;
  final int totalCount;

  const AiAnalysisHistoryLoaded({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [items, page, hasMore, totalCount];
}

class AiAnalysisSaving extends AiAnalysisState {
  const AiAnalysisSaving();
}

class AiAnalysisSaved extends AiAnalysisState {
  final ReportHistoryItemEntity report;

  const AiAnalysisSaved(this.report);

  @override
  List<Object?> get props => [report];
}

class AiAnalysisError extends AiAnalysisState {
  final String message;

  const AiAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
