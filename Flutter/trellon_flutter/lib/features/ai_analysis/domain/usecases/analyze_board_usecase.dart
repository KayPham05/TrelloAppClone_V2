import '../entities/project_analysis_entity.dart';
import '../repositories/i_ai_analysis_repository.dart';

class AnalyzeBoardUseCase {
  final IAiAnalysisRepository repository;

  AnalyzeBoardUseCase(this.repository);

  Future<ProjectAnalysisEntity> call({
    required String boardUId,
    required String userUId,
    bool forceRefresh = false,
  }) {
    return repository.analyzeBoard(
      boardUId: boardUId,
      userUId: userUId,
      forceRefresh: forceRefresh,
    );
  }
}
