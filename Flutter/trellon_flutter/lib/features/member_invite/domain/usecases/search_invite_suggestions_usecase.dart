import '../entities/invite_suggestion.dart';
import '../repositories/invite_suggestion_repository.dart';

class SearchInviteSuggestionsUseCase {
  final InviteSuggestionRepository repository;

  SearchInviteSuggestionsUseCase(this.repository);

  Future<List<InviteSuggestion>> call({
    required String query,
    required String scope,
    required String requesterUId,
    String? workspaceId,
    String? boardId,
    int limit = 10,
  }) {
    return repository.search(
      query: query,
      scope: scope,
      requesterUId: requesterUId,
      workspaceId: workspaceId,
      boardId: boardId,
      limit: limit,
    );
  }
}
