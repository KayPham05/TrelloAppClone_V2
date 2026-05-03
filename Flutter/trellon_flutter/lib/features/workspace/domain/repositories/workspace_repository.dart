import '../entities/workspace_entity.dart';
import '../../../board/domain/entities/board_entity.dart';

abstract class WorkspaceRepository {
  Future<List<WorkspaceEntity>> getWorkspaces(String userUid);
  Future<List<BoardEntity>> getWorkspaceBoards(String workspaceId, String userUid);
  Future<WorkspaceEntity> createWorkspace({
    required String name,
    required String? description,
    required WorkspaceType type,
    required String userUId,
  });
  Future<void> updateWorkspace({
    required String workspaceId,
    required String name,
    required String? description,
    required WorkspaceType type,
    required String userUId,
  });
  Future<void> deleteWorkspace({
    required String workspaceId,
    required String userUId,
  });
  Future<void> addWorkspaceMember({
    required String workspaceId,
    required String email,
    required String role,
    required String requesterUId,
  });
}
