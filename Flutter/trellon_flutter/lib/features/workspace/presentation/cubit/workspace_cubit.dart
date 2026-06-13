import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/workspace_entity.dart';
import '../../domain/usecases/get_workspaces_usecase.dart';
import '../../domain/usecases/create_workspace_usecase.dart';
import '../../domain/usecases/update_workspace_usecase.dart';
import '../../domain/usecases/delete_workspace_usecase.dart';
import '../../domain/usecases/add_workspace_member_usecase.dart';
import '../../domain/usecases/update_workspace_board_visibility_usecase.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../board/domain/usecases/create_board_usecase.dart';
import '../../../board/domain/usecases/delete_board_usecase.dart';
import '../../../board/domain/usecases/set_board_starred_usecase.dart';
import '../../../board/domain/usecases/update_board_usecase.dart';
import '../../../../core/services/authorization_service.dart';
import '../../../member_invite/domain/entities/invite_batch_result.dart';

abstract class WorkspaceState {}

class WorkspaceInitial extends WorkspaceState {}

class WorkspaceLoading extends WorkspaceState {}

class WorkspaceLoaded extends WorkspaceState {
  final List<WorkspaceEntity> personal;
  final List<WorkspaceEntity> team;
  WorkspaceLoaded({required this.personal, required this.team});
}

class WorkspaceError extends WorkspaceState {
  final String message;
  WorkspaceError(this.message);
}

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final GetWorkspacesUseCase getWorkspacesUseCase;
  final CreateWorkspaceUseCase createWorkspaceUseCase;
  final UpdateWorkspaceUseCase updateWorkspaceUseCase;
  final DeleteWorkspaceUseCase deleteWorkspaceUseCase;
  final AddWorkspaceMemberUseCase addWorkspaceMemberUseCase;
  final UpdateWorkspaceBoardVisibilityUseCase
  updateWorkspaceBoardVisibilityUseCase;
  final CreateBoardUseCase createBoardUseCase;
  final DeleteBoardUseCase deleteBoardUseCase;
  final SetBoardStarredUseCase setBoardStarredUseCase;
  final UpdateBoardUseCase updateBoardUseCase;
  final UserLocalDataSource userLocalDataSource;

  WorkspaceCubit({
    required this.getWorkspacesUseCase,
    required this.createWorkspaceUseCase,
    required this.updateWorkspaceUseCase,
    required this.deleteWorkspaceUseCase,
    required this.addWorkspaceMemberUseCase,
    required this.updateWorkspaceBoardVisibilityUseCase,
    required this.createBoardUseCase,
    required this.deleteBoardUseCase,
    required this.setBoardStarredUseCase,
    required this.updateBoardUseCase,
    required this.userLocalDataSource,
  }) : super(WorkspaceInitial());

  Future<void> loadWorkspaces() async {
    emit(WorkspaceLoading());
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      final workspaces = await getWorkspacesUseCase(userUid);

      final activeWorkspaces = workspaces
          .where((w) => w.status != 'Deleted')
          .toList();
      final personal = activeWorkspaces
          .where((w) => w.type == WorkspaceType.personal)
          .toList();
      final team = activeWorkspaces
          .where((w) => w.type == WorkspaceType.team)
          .toList();

      emit(WorkspaceLoaded(personal: personal, team: team));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> createWorkspace(
    String name,
    String? description,
    WorkspaceType type,
  ) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await createWorkspaceUseCase(
        name: name,
        description: description,
        type: type,
        userUId: userUid,
      );
      await loadWorkspaces();
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<bool> updateWorkspace(
    String id,
    String name,
    String? description,
    WorkspaceType type,
  ) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';

      // Permission check
      final currentState = state;
      if (currentState is WorkspaceLoaded) {
        final workspaces = [...currentState.personal, ...currentState.team];
        final workspace = workspaces.where((w) => w.id == id).firstOrNull;
        if (workspace != null) {
          final role = workspace.getUserRole(userUid);
          if (!AuthorizationService().canManageWorkspace(role)) {
            if (!isClosed) {
              emit(
                WorkspaceError('Bạn không có quyền chỉnh sửa không gian này.'),
              );
            }
            return false;
          }
        }
      }

      await updateWorkspaceUseCase(
        workspaceId: id,
        name: name,
        description: description,
        type: type,
        userUId: userUid,
      );
      if (!isClosed) await loadWorkspaces();
      return true;
    } catch (e) {
      if (!isClosed) emit(WorkspaceError(_friendlyWorkspaceError(e)));
      return false;
    }
  }

  Future<void> deleteWorkspace(String id) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';

      // Permission check
      final currentState = state;
      if (currentState is WorkspaceLoaded) {
        final workspaces = [...currentState.personal, ...currentState.team];
        final workspace = workspaces.where((w) => w.id == id).firstOrNull;
        if (workspace != null) {
          final role = workspace.getUserRole(userUid);
          if (!AuthorizationService().canManageWorkspace(role)) {
            if (!isClosed) {
              emit(WorkspaceError('Bạn không có quyền xóa không gian này.'));
            }
            return;
          }
        }
      }

      await deleteWorkspaceUseCase(workspaceId: id, userUId: userUid);
      if (!isClosed) await loadWorkspaces();
    } catch (e) {
      if (!isClosed) emit(WorkspaceError(e.toString()));
    }
  }

  Future<bool> addMember(String workspaceId, String userIdentifier) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await addWorkspaceMemberUseCase(
        workspaceId: workspaceId,
        userId: userIdentifier,
        role: 'Member',
        requesterUId: userUid,
      );
      return true;
    } catch (e) {
      if (!isClosed) emit(WorkspaceError(_friendlyWorkspaceError(e)));
      return false;
    }
  }

  Future<InviteBatchResult> addMembersByUserIds({
    required String workspaceId,
    required List<String> userIds,
  }) async {
    var success = 0;
    var failure = 0;
    final requesterUId = await userLocalDataSource.getUserId() ?? '';

    for (final userId in userIds) {
      try {
        await addWorkspaceMemberUseCase(
          workspaceId: workspaceId,
          userId: userId,
          role: 'Member',
          requesterUId: requesterUId,
        );
        success++;
      } catch (_) {
        failure++;
      }
    }

    if (success > 0 && !isClosed) {
      await loadWorkspaces();
    }

    return InviteBatchResult(successCount: success, failureCount: failure);
  }

  String _friendlyWorkspaceError(Object error) {
    final message = error.toString();
    if (message.contains('403')) {
      return 'Bạn không có quyền thực hiện thao tác này.';
    }
    if (message.contains('404')) {
      return 'Không tìm thấy không gian làm việc hoặc người dùng.';
    }
    if (message.contains('Failed to add workspace member')) {
      return 'Không thể mời thành viên vào không gian làm việc.';
    }
    return 'Không thể thực hiện thao tác với không gian làm việc.';
  }

  Future<void> createBoard(
    String workspaceId,
    String name,
    String? backgroundUrl,
  ) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await createBoardUseCase(
        name: name,
        workspaceId: workspaceId,
        userUid: userUid,
        backgroundUrl: backgroundUrl,
      );
      await loadWorkspaces();
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> deleteBoard(String boardId) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await deleteBoardUseCase(boardId: boardId, userUId: userUid);
      // Let SignalR handle the UI update or manually refresh:
      await loadWorkspaces();
    } catch (e) {
      emit(
        WorkspaceError('Không thể xóa bảng. Cần quyền Owner. ${e.toString()}'),
      );
    }
  }

  Future<bool> updateBoardVisibility({
    required String boardId,
    required String boardName,
    required String workspaceId,
    required String visibility,
  }) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await updateWorkspaceBoardVisibilityUseCase(
        boardId: boardId,
        boardName: boardName,
        workspaceId: workspaceId,
        visibility: visibility,
        userUId: userUid,
      );
      await loadWorkspaces();
      return true;
    } catch (e) {
      if (!isClosed) emit(WorkspaceError(_friendlyWorkspaceError(e)));
      return false;
    }
  }

  Future<bool> renameBoard({
    required String boardId,
    required String boardName,
    required String workspaceId,
    required String visibility,
  }) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await updateBoardUseCase(
        boardId: boardId,
        boardName: boardName.trim(),
        workspaceUId: workspaceId,
        visibility: visibility,
        userUId: userUid,
      );
      await loadWorkspaces();
      return true;
    } catch (e) {
      if (!isClosed) emit(WorkspaceError(_friendlyWorkspaceError(e)));
      return false;
    }
  }

  Future<bool> setBoardStarred({
    required String boardId,
    required bool isStarred,
  }) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await setBoardStarredUseCase(
        userUid: userUid,
        boardId: boardId,
        isStarred: isStarred,
      );
      await loadWorkspaces();
      return true;
    } catch (e) {
      if (!isClosed) emit(WorkspaceError(_friendlyWorkspaceError(e)));
      return false;
    }
  }

  void reset() {
    emit(WorkspaceInitial());
  }

  void applyRealtimeWorkspaceUpdated(Map<String, dynamic> payload) {
    final currentState = state;
    if (currentState is WorkspaceLoaded) {
      final updatedPersonal = currentState.personal.map((w) {
        if (w.id == payload['workspaceId']) {
          return w.copyWith(
            name: payload['name'],
            description: payload['description'],
          );
        }
        return w;
      }).toList();

      final updatedTeam = currentState.team.map((w) {
        if (w.id == payload['workspaceId']) {
          return w.copyWith(
            name: payload['name'],
            description: payload['description'],
          );
        }
        return w;
      }).toList();

      emit(WorkspaceLoaded(personal: updatedPersonal, team: updatedTeam));
    }
  }

  void applyRealtimeWorkspaceDeleted(String workspaceId) {
    final currentState = state;
    if (currentState is WorkspaceLoaded) {
      final updatedPersonal = currentState.personal
          .where((w) => w.id != workspaceId)
          .toList();
      final updatedTeam = currentState.team
          .where((w) => w.id != workspaceId)
          .toList();
      emit(WorkspaceLoaded(personal: updatedPersonal, team: updatedTeam));
    }
  }
}
