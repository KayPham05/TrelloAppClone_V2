import '../../../board/domain/entities/board_entity.dart';
import '../repositories/workspace_repository.dart';

class GetWorkspaceBoardsUseCase {
  final WorkspaceRepository repository;
  GetWorkspaceBoardsUseCase(this.repository);

  Future<List<BoardEntity>> call(String workspaceId, String userUid) async {
    return await repository.getWorkspaceBoards(workspaceId, userUid);
  }
}
