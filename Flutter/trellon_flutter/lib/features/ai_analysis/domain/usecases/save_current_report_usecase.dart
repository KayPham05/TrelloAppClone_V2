import '../entities/report_history_item_entity.dart';
import '../repositories/i_ai_analysis_repository.dart';

class SaveCurrentReportUseCase {
  final IAiAnalysisRepository repository;

  SaveCurrentReportUseCase(this.repository);

  Future<ReportHistoryItemEntity> call({
    required String scopeType,
    required String scopeUId,
  }) {
    return repository.saveCurrentReport(
      scopeType: scopeType,
      scopeUId: scopeUId,
    );
  }
}
