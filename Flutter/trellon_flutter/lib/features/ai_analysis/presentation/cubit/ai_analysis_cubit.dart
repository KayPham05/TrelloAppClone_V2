import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/project_analysis_entity.dart';
import '../../domain/usecases/analyze_board_usecase.dart';
import '../../domain/usecases/analyze_card_usecase.dart';
import '../../domain/usecases/analyze_workspace_usecase.dart';
import 'ai_analysis_state.dart';

class AiAnalysisCubit extends Cubit<AiAnalysisState> {
  final AnalyzeWorkspaceUseCase analyzeWorkspaceUseCase;
  final AnalyzeBoardUseCase analyzeBoardUseCase;
  final AnalyzeCardUseCase analyzeCardUseCase;

  AiAnalysisCubit({
    required this.analyzeWorkspaceUseCase,
    required this.analyzeBoardUseCase,
    required this.analyzeCardUseCase,
  }) : super(const AiAnalysisInitial());

  Future<void> analyze({
    required String scopeType,
    required String scopeUId,
    required String userUId,
  }) async {
    emit(const AiAnalysisLoading());
    try {
      final analysis = await _analyzeByScope(
        scopeType: scopeType,
        scopeUId: scopeUId,
        userUId: userUId,
      );
      emit(AiAnalysisLoaded(analysis));
    } catch (error) {
      emit(AiAnalysisError(_cleanMessage(error)));
    }
  }

  void showError(String message) {
    emit(AiAnalysisError(message));
  }

  Future<ProjectAnalysisEntity> _analyzeByScope({
    required String scopeType,
    required String scopeUId,
    required String userUId,
  }) {
    switch (scopeType.toLowerCase()) {
      case 'workspace':
        return analyzeWorkspaceUseCase(
          workspaceUId: scopeUId,
          userUId: userUId,
        );
      case 'card':
        return analyzeCardUseCase(cardUId: scopeUId, userUId: userUId);
      case 'board':
      default:
        return analyzeBoardUseCase(boardUId: scopeUId, userUId: userUId);
    }
  }

  String _cleanMessage(Object error) {
    final raw = error.toString();
    return raw.startsWith('Exception: ') ? raw.substring(11) : raw;
  }
}
