import '../entities/project_analysis_entity.dart';
import '../entities/report_history_item_entity.dart';
import '../entities/report_history_page_entity.dart';

abstract class IAiAnalysisRepository {
  Future<ProjectAnalysisEntity> analyzeWorkspace({
    required String workspaceUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisEntity> analyzeBoard({
    required String boardUId,
    bool forceRefresh = false,
  });

  Future<ProjectAnalysisEntity> analyzeCard({
    required String cardUId,
    bool forceRefresh = false,
  });

  Future<ReportHistoryPageEntity> getReportHistory({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  });

  Future<ReportHistoryItemEntity> saveCurrentReport({
    required String scopeType,
    required String scopeUId,
  });

  Future<ProjectAnalysisEntity> getReportById({required String reportUId});
}
