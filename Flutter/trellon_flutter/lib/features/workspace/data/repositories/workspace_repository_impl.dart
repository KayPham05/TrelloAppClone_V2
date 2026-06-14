import '../datasources/workspace_remote_data_source.dart';
import '../../domain/entities/workspace_entity.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../../board/domain/entities/board_entity.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource remoteDataSource;

  WorkspaceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<WorkspaceEntity>> getWorkspaces(String userUid) async {
    try {
      return await remoteDataSource.getWorkspaces(userUid);
    } catch (e) {
      throw Exception('Workspace Repository Error: $e');
    }
  }

  @override
  Future<List<BoardEntity>> getWorkspaceBoards(
    String workspaceId,
    String userUid,
  ) async {
    try {
      return await remoteDataSource.getWorkspaceBoards(workspaceId, userUid);
    } catch (e) {
      throw Exception('Workspace Repository Error: $e');
    }
  }

  @override
  Future<WorkspaceEntity> createWorkspace({
    required String name,
    required String? description,
    required WorkspaceType type,
    required String userUId,
  }) async {
    try {
      return await remoteDataSource.createWorkspace(
        name: name,
        description: description,
        type: type.toShortString(),
        userUId: userUId,
      );
    } catch (e) {
      throw Exception('Workspace Repository Error: $e');
    }
  }

  @override
  Future<void> updateWorkspace({
    required String workspaceId,
    required String name,
    required String? description,
    required WorkspaceType type,
    required String userUId,
  }) async {
    try {
      await remoteDataSource.updateWorkspace(
        workspaceId: workspaceId,
        name: name,
        description: description,
        type: type.toShortString(),
        userUId: userUId,
      );
    } catch (e) {
      throw Exception('Workspace Repository Error: $e');
    }
  }

  @override
  Future<void> deleteWorkspace({
    required String workspaceId,
    required String userUId,
  }) async {
    try {
      await remoteDataSource.deleteWorkspace(
        workspaceId: workspaceId,
        userUId: userUId,
      );
    } catch (e) {
      throw Exception('Workspace Repository Error: $e');
    }
  }

  @override
  Future<void> addWorkspaceMember({
    required String workspaceId,
    required String userId,
    required String role,
    required String requesterUId,
  }) async {
    try {
      await remoteDataSource.addWorkspaceMember(
        workspaceId: workspaceId,
        userId: userId,
        role: role,
        requesterUId: requesterUId,
      );
    } catch (e) {
      throw Exception('Workspace Repository Error: $e');
    }
  }

  @override
  Future<void> updateBoardVisibility({
    required String boardId,
    required String boardName,
    required String workspaceId,
    required String visibility,
    required String userUId,
  }) async {
    try {
      await remoteDataSource.updateBoardVisibility(
        boardId: boardId,
        boardName: boardName,
        workspaceId: workspaceId,
        visibility: visibility,
        userUId: userUId,
      );
    } catch (e) {
      throw Exception('Workspace Repository Error: $e');
    }
  }
}
