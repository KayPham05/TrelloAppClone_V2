import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/project_analysis_entity.dart';
import '../../domain/usecases/analyze_board_usecase.dart';
import '../../domain/usecases/analyze_card_usecase.dart';
import '../../domain/usecases/analyze_workspace_usecase.dart';
import '../../domain/usecases/get_report_by_id_usecase.dart';
import '../../domain/usecases/get_report_history_usecase.dart';
import '../../domain/usecases/save_current_report_usecase.dart';
import 'ai_analysis_state.dart';

class AiAnalysisCubit extends Cubit<AiAnalysisState> {
  final AnalyzeWorkspaceUseCase analyzeWorkspaceUseCase;
  final AnalyzeBoardUseCase analyzeBoardUseCase;
  final AnalyzeCardUseCase analyzeCardUseCase;
  final GetReportHistoryUseCase getReportHistoryUseCase;
  final GetReportByIdUseCase getReportByIdUseCase;
  final SaveCurrentReportUseCase saveCurrentReportUseCase;

  AiAnalysisCubit({
    required this.analyzeWorkspaceUseCase,
    required this.analyzeBoardUseCase,
    required this.analyzeCardUseCase,
    required this.getReportHistoryUseCase,
    required this.getReportByIdUseCase,
    required this.saveCurrentReportUseCase,
  }) : super(const AiAnalysisInitial());

  Future<void> analyze({
    required String scopeType,
    required String scopeUId,
    bool forceRefresh = false,
  }) async {
    emit(const AiAnalysisLoading());
    try {
      final analysis = await _analyzeByScope(
        scopeType: scopeType,
        scopeUId: scopeUId,
        forceRefresh: forceRefresh,
      );
      emit(AiAnalysisLoaded(analysis));
    } catch (error) {
      emit(AiAnalysisError(_cleanMessage(error)));
    }
  }

  void showError(String message) {
    emit(AiAnalysisError(message));
  }

  void showLoaded(ProjectAnalysisEntity analysis) {
    emit(AiAnalysisLoaded(analysis));
  }

  Future<void> loadHistory({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  }) async {
    emit(const AiAnalysisLoading());
    try {
      final result = await getReportHistoryUseCase(
        scopeType: scopeType,
        scopeUId: scopeUId,
        page: page,
        pageSize: pageSize,
      );
      emit(
        AiAnalysisHistoryLoaded(
          items: result.items,
          page: result.page,
          hasMore: result.hasMore,
          totalCount: result.totalCount,
        ),
      );
    } catch (error) {
      emit(AiAnalysisError(_cleanMessage(error)));
    }
  }

  Future<void> loadReport({required String reportUId}) async {
    emit(const AiAnalysisLoading());
    try {
      final analysis = await getReportByIdUseCase(reportUId: reportUId);
      emit(AiAnalysisLoaded(analysis));
    } catch (error) {
      emit(AiAnalysisError(_cleanMessage(error)));
    }
  }

  Future<void> saveCurrentReport({
    required String scopeType,
    required String scopeUId,
  }) async {
    emit(const AiAnalysisSaving());
    try {
      final report = await saveCurrentReportUseCase(
        scopeType: scopeType,
        scopeUId: scopeUId,
      );
      emit(AiAnalysisSaved(report));
    } catch (error) {
      emit(AiAnalysisError(_cleanMessage(error)));
    }
  }

  Future<ProjectAnalysisEntity> _analyzeByScope({
    required String scopeType,
    required String scopeUId,
    bool forceRefresh = false,
  }) {
    switch (scopeType.toLowerCase()) {
      case 'workspace':
        return analyzeWorkspaceUseCase(
          workspaceUId: scopeUId,
          forceRefresh: forceRefresh,
        );
      case 'card':
        return analyzeCardUseCase(
          cardUId: scopeUId,
          forceRefresh: forceRefresh,
        );
      case 'board':
      default:
        return analyzeBoardUseCase(
          boardUId: scopeUId,
          forceRefresh: forceRefresh,
        );
    }
  }

  String _cleanMessage(Object error) {
    final raw = error.toString();
    return raw.startsWith('Exception: ') ? raw.substring(11) : raw;
  }
}
