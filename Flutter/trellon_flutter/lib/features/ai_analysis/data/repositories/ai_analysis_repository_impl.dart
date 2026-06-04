import '../../domain/entities/project_analysis_entity.dart';
import '../../domain/entities/report_history_item_entity.dart';
import '../../domain/entities/report_history_page_entity.dart';
import '../../domain/repositories/i_ai_analysis_repository.dart';
import '../datasources/ai_analysis_remote_data_source.dart';

class AiAnalysisRepositoryImpl implements IAiAnalysisRepository {
  final AiAnalysisRemoteDataSource remoteDataSource;

  AiAnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProjectAnalysisEntity> analyzeWorkspace({
    required String workspaceUId,
    bool forceRefresh = false,
  }) async {
    final result = await remoteDataSource.analyzeWorkspace(
      workspaceUId: workspaceUId,
      forceRefresh: forceRefresh,
    );
    return result.toEntity();
  }

  @override
  Future<ProjectAnalysisEntity> analyzeBoard({
    required String boardUId,
    bool forceRefresh = false,
  }) async {
    final result = await remoteDataSource.analyzeBoard(
      boardUId: boardUId,
      forceRefresh: forceRefresh,
    );
    return result.toEntity();
  }

  @override
  Future<ProjectAnalysisEntity> analyzeCard({
    required String cardUId,
    bool forceRefresh = false,
  }) async {
    final result = await remoteDataSource.analyzeCard(
      cardUId: cardUId,
      forceRefresh: forceRefresh,
    );
    return result.toEntity();
  }

  @override
  Future<ReportHistoryPageEntity> getReportHistory({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  }) async {
    final result = await remoteDataSource.getReportHistory(
      scopeType: scopeType,
      scopeUId: scopeUId,
      page: page,
      pageSize: pageSize,
    );
    return result.toEntity();
  }

  @override
  Future<ReportHistoryItemEntity> saveCurrentReport({
    required String scopeType,
    required String scopeUId,
  }) async {
    final result = await remoteDataSource.saveCurrentReport(
      scopeType: scopeType,
      scopeUId: scopeUId,
    );
    return result.toEntity();
  }

  @override
  Future<ProjectAnalysisEntity> getReportById({
    required String reportUId,
  }) async {
    final result = await remoteDataSource.getReportById(reportUId: reportUId);
    return result.toEntity();
  }
}
