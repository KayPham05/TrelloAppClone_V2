import '../entities/report_history_page_entity.dart';
import '../repositories/i_ai_analysis_repository.dart';

class GetReportHistoryUseCase {
  final IAiAnalysisRepository repository;

  GetReportHistoryUseCase(this.repository);

  Future<ReportHistoryPageEntity> call({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  }) {
    return repository.getReportHistory(
      scopeType: scopeType,
      scopeUId: scopeUId,
      page: page,
      pageSize: pageSize,
    );
  }
}
