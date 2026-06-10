import '../entities/project_analysis_entity.dart';
import '../repositories/i_ai_analysis_repository.dart';

class GetReportByIdUseCase {
  final IAiAnalysisRepository repository;

  GetReportByIdUseCase(this.repository);

  Future<ProjectAnalysisEntity> call({required String reportUId}) {
    return repository.getReportById(reportUId: reportUId);
  }
}
