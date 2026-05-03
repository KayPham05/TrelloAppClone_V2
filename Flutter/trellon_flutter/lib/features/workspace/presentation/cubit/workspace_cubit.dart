import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/workspace_entity.dart';
import '../../domain/usecases/get_workspaces_usecase.dart';
import '../../domain/usecases/create_workspace_usecase.dart';
import '../../domain/usecases/update_workspace_usecase.dart';
import '../../domain/usecases/delete_workspace_usecase.dart';
import '../../domain/usecases/add_workspace_member_usecase.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../board/domain/usecases/create_board_usecase.dart';

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
  final CreateBoardUseCase createBoardUseCase;
  final UserLocalDataSource userLocalDataSource;

  WorkspaceCubit({
    required this.getWorkspacesUseCase,
    required this.createWorkspaceUseCase,
    required this.updateWorkspaceUseCase,
    required this.deleteWorkspaceUseCase,
    required this.addWorkspaceMemberUseCase,
    required this.createBoardUseCase,
    required this.userLocalDataSource,
  }) : super(WorkspaceInitial());

  Future<void> loadWorkspaces() async {
    emit(WorkspaceLoading());
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      final workspaces = await getWorkspacesUseCase(userUid);
      
      final personal = workspaces.where((w) => w.type == WorkspaceType.personal).toList();
      final team = workspaces.where((w) => w.type == WorkspaceType.team).toList();
      
      emit(WorkspaceLoaded(personal: personal, team: team));
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> createWorkspace(String name, String? description, WorkspaceType type) async {
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

  Future<void> updateWorkspace(String id, String name, String? description, WorkspaceType type) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await updateWorkspaceUseCase(
        workspaceId: id,
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

  Future<void> deleteWorkspace(String id) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await deleteWorkspaceUseCase(workspaceId: id, userUId: userUid);
      await loadWorkspaces();
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> addMember(String workspaceId, String email) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await addWorkspaceMemberUseCase(
        workspaceId: workspaceId,
        email: email,
        role: 'Member',
        requesterUId: userUid,
      );
    } catch (e) {
      emit(WorkspaceError(e.toString()));
    }
  }

  Future<void> createBoard(String workspaceId, String name, String? backgroundUrl) async {
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
}
