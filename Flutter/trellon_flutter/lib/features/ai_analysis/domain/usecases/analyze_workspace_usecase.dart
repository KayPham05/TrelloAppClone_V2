import '../entities/project_analysis_entity.dart';
import '../repositories/i_ai_analysis_repository.dart';

class AnalyzeWorkspaceUseCase {
  final IAiAnalysisRepository repository;

  AnalyzeWorkspaceUseCase(this.repository);

  Future<ProjectAnalysisEntity> call({
    required String workspaceUId,
    required String userUId,
  }) {
    return repository.analyzeWorkspace(
      workspaceUId: workspaceUId,
      userUId: userUId,
    );
  }
}
