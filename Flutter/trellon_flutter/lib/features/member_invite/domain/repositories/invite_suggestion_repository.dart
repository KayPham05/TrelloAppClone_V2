import '../entities/invite_suggestion.dart';

abstract class InviteSuggestionRepository {
  Future<List<InviteSuggestion>> search({
    required String query,
    required String scope,
    required String requesterUId,
    String? workspaceId,
    String? boardId,
    int limit,
  });
}
