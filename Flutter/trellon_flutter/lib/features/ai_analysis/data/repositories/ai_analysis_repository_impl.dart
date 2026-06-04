import '../../domain/entities/project_analysis_entity.dart';
import '../../domain/repositories/i_ai_analysis_repository.dart';
import '../datasources/ai_analysis_remote_data_source.dart';

class AiAnalysisRepositoryImpl implements IAiAnalysisRepository {
  final AiAnalysisRemoteDataSource remoteDataSource;

  AiAnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProjectAnalysisEntity> analyzeWorkspace({
    required String workspaceUId,
    required String userUId,
    bool forceRefresh = false,
  }) async {
    final result = await remoteDataSource.analyzeWorkspace(
      workspaceUId: workspaceUId,
      userUId: userUId,
      forceRefresh: forceRefresh,
    );
    return result.toEntity();
  }

  @override
  Future<ProjectAnalysisEntity> analyzeBoard({
    required String boardUId,
    required String userUId,
    bool forceRefresh = false,
  }) async {
    final result = await remoteDataSource.analyzeBoard(
      boardUId: boardUId,
      userUId: userUId,
      forceRefresh: forceRefresh,
    );
    return result.toEntity();
  }

  @override
  Future<ProjectAnalysisEntity> analyzeCard({
    required String cardUId,
    required String userUId,
    bool forceRefresh = false,
  }) async {
    final result = await remoteDataSource.analyzeCard(
      cardUId: cardUId,
      userUId: userUId,
      forceRefresh: forceRefresh,
    );
    return result.toEntity();
  }
}
