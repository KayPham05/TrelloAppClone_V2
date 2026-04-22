import '../repositories/workspace_repository.dart';

class DeleteWorkspaceUseCase {
  final WorkspaceRepository repository;
  DeleteWorkspaceUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String userUId,
  }) async {
    return await repository.deleteWorkspace(
      workspaceId: workspaceId,
      userUId: userUId,
    );
  }
}
