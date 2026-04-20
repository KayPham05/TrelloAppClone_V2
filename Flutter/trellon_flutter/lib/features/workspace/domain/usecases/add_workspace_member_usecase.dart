import '../repositories/workspace_repository.dart';

class AddWorkspaceMemberUseCase {
  final WorkspaceRepository repository;
  AddWorkspaceMemberUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    return await repository.addWorkspaceMember(
      workspaceId: workspaceId,
      email: email,
      role: role,
    );
  }
}
