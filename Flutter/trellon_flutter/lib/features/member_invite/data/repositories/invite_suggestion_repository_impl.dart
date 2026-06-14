import '../../domain/entities/invite_suggestion.dart';
import '../../domain/repositories/invite_suggestion_repository.dart';
import '../datasources/invite_suggestion_remote_data_source.dart';

class InviteSuggestionRepositoryImpl implements InviteSuggestionRepository {
  final InviteSuggestionRemoteDataSource remoteDataSource;

  InviteSuggestionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InviteSuggestion>> search({
    required String query,
    required String scope,
    required String requesterUId,
    String? workspaceId,
    String? boardId,
    int limit = 10,
  }) {
    return remoteDataSource.search(
      query: query,
      scope: scope,
      requesterUId: requesterUId,
      workspaceId: workspaceId,
      boardId: boardId,
      limit: limit,
    );
  }
}
