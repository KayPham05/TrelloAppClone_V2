import '../repositories/workspace_repository.dart';

class AddWorkspaceMemberUseCase {
  final WorkspaceRepository repository;
  AddWorkspaceMemberUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String userId,
    required String role,
    required String requesterUId,
  }) async {
    return await repository.addWorkspaceMember(
      workspaceId: workspaceId,
      userId: userId,
      role: role,
      requesterUId: requesterUId,
    );
  }
}
