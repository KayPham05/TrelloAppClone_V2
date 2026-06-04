import '../entities/project_analysis_entity.dart';

abstract class IAiAnalysisRepository {
  Future<ProjectAnalysisEntity> analyzeWorkspace({
    required String workspaceUId,
    required String userUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisEntity> analyzeBoard({
    required String boardUId,
    required String userUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisEntity> analyzeCard({
    required String cardUId,
    required String userUId,
    bool forceRefresh = false,
  });
}
