import '../repositories/workspace_repository.dart';

class UpdateWorkspaceBoardVisibilityUseCase {
  final WorkspaceRepository repository;
  UpdateWorkspaceBoardVisibilityUseCase(this.repository);

  Future<void> call({
    required String boardId,
    required String boardName,
    required String workspaceId,
    required String visibility,
    required String userUId,
  }) async {
    return await repository.updateBoardVisibility(
      boardId: boardId,
      boardName: boardName,
      workspaceId: workspaceId,
      visibility: visibility,
      userUId: userUId,
    );
  }
}
