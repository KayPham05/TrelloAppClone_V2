import '../entities/workspace_entity.dart';
import '../repositories/workspace_repository.dart';

class UpdateWorkspaceUseCase {
  final WorkspaceRepository repository;
  UpdateWorkspaceUseCase(this.repository);

  Future<void> call({
    required String workspaceId,
    required String name,
    required String? description,
    required WorkspaceType type,
    required String userUId,
  }) async {
    return await repository.updateWorkspace(
      workspaceId: workspaceId,
      name: name,
      description: description,
      type: type,
      userUId: userUId,
    );
  }
}
