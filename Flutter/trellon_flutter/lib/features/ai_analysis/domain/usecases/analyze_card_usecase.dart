import '../entities/project_analysis_entity.dart';
import '../repositories/i_ai_analysis_repository.dart';

class AnalyzeCardUseCase {
  final IAiAnalysisRepository repository;

  AnalyzeCardUseCase(this.repository);

  Future<ProjectAnalysisEntity> call({
    required String cardUId,
    bool forceRefresh = false,
  }) {
    return repository.analyzeCard(cardUId: cardUId, forceRefresh: forceRefresh);
  }
}
