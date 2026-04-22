import '../entities/workspace_entity.dart';
import '../repositories/workspace_repository.dart';

class CreateWorkspaceUseCase {
  final WorkspaceRepository repository;
  CreateWorkspaceUseCase(this.repository);

  Future<WorkspaceEntity> call({
    required String name,
    required String? description,
    required WorkspaceType type,
    required String userUId,
  }) async {
    return await repository.createWorkspace(
      name: name,
      description: description,
      type: type,
      userUId: userUId,
    );
  }
}
