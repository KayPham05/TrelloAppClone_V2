import '../entities/workspace_entity.dart';
import '../repositories/workspace_repository.dart';

class GetWorkspacesUseCase {
  final WorkspaceRepository repository;

  GetWorkspacesUseCase(this.repository);

  Future<List<WorkspaceEntity>> call(String userUid) async {
    return await repository.getWorkspaces(userUid);
  }
}
