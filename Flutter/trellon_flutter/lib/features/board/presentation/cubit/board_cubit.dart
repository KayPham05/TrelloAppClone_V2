import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../workspace/domain/entities/workspace_entity.dart';
import '../../domain/entities/board_entity.dart';
import '../../domain/usecases/get_personal_boards_usecase.dart';
import '../../domain/usecases/get_recent_boards_usecase.dart';
import '../../domain/usecases/get_starred_boards_usecase.dart';
import '../../domain/usecases/create_board_usecase.dart';
import '../../domain/usecases/set_board_starred_usecase.dart';
import '../../domain/usecases/update_board_usecase.dart';
import '../../../workspace/domain/usecases/get_workspaces_usecase.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../core/errors/app_exception_mapper.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class BoardState extends Equatable {
  const BoardState();
  @override
  List<Object?> get props => [];
}

class BoardInitial extends BoardState {}

class BoardLoading extends BoardState {}

class BoardLoaded extends BoardState {
  final List<BoardEntity> personalBoards;
  final List<WorkspaceEntity> guestWorkspaces;
  final List<WorkspaceEntity> allWorkspaces;
  final List<BoardEntity> recentBoards;
  final List<BoardEntity> starredBoards;

  const BoardLoaded({
    required this.personalBoards,
    required this.guestWorkspaces,
    required this.allWorkspaces,
    required this.recentBoards,
    required this.starredBoards,
  });

  @override
  List<Object?> get props => [
    personalBoards,
    guestWorkspaces,
    allWorkspaces,
    recentBoards,
    starredBoards,
  ];
}

class BoardError extends BoardState {
  final String message;
  const BoardError({required this.message});
  @override
  List<Object?> get props => [message];
}

class BoardCreating extends BoardState {}

class BoardCreated extends BoardState {}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class BoardCubit extends Cubit<BoardState> {
  final GetPersonalBoardsUseCase getPersonalBoardsUseCase;
  final GetWorkspacesUseCase getWorkspacesUseCase;
  final GetRecentBoardsUseCase getRecentBoardsUseCase;
  final GetStarredBoardsUseCase getStarredBoardsUseCase;
  final CreateBoardUseCase createBoardUseCase;
  final SetBoardStarredUseCase setBoardStarredUseCase;
  final UpdateBoardUseCase updateBoardUseCase;
  final UserLocalDataSource userLocalDataSource;

  BoardCubit({
    required this.getPersonalBoardsUseCase,
    required this.getWorkspacesUseCase,
    required this.getRecentBoardsUseCase,
    required this.getStarredBoardsUseCase,
    required this.createBoardUseCase,
    required this.setBoardStarredUseCase,
    required this.updateBoardUseCase,
    required this.userLocalDataSource,
  }) : super(BoardInitial());

  Future<void> fetchBoardData(
    String userUid,
    String userName, {
    bool showLoading = true,
  }) async {
    if (showLoading) emit(BoardLoading());

    try {
      final results = await Future.wait([
        getPersonalBoardsUseCase(userUid),
        getWorkspacesUseCase(userUid),
        getRecentBoardsUseCase(userUid),
        getStarredBoardsUseCase(userUid),
      ]);

      final personalBoards = results[0] as List<BoardEntity>;
      final allWorkspaces = results[1] as List<WorkspaceEntity>;
      final recentBoards = results[2] as List<BoardEntity>;
      final starredBoards = results[3] as List<BoardEntity>;

      final guestWorkspaces = allWorkspaces
          .where((workspace) => workspace.ownerUId != userUid)
          .toList();

      emit(
        BoardLoaded(
          personalBoards: personalBoards,
          guestWorkspaces: guestWorkspaces,
          allWorkspaces: allWorkspaces,
          recentBoards: recentBoards,
          starredBoards: starredBoards,
        ),
      );
    } catch (e) {
      emit(BoardError(message: AppExceptionMapper.map(e)));
    }
  }

  /// Creates a personal board (no workspace required).
  Future<void> createPersonalBoard({
    required String name,
    String visibility = 'Private',
  }) async {
    emit(BoardCreating());
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await createBoardUseCase(
        name: name,
        userUid: userUid,
        isPersonal: true,
        visibility: visibility,
      );
      emit(BoardCreated());
      await fetchBoardData(userUid, '');
    } catch (e) {
      emit(BoardError(message: AppExceptionMapper.map(e)));
    }
  }

  /// Creates a board inside a workspace.
  Future<void> createBoard({
    required String name,
    required String workspaceId,
    bool isPersonal = false,
    String? visibility,
    String? coverColor,
  }) async {
    emit(BoardCreating());
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      await createBoardUseCase(
        name: name,
        userUid: userUid,
        workspaceId: workspaceId,
        isPersonal: isPersonal,
        visibility: visibility ?? 'Private',
        coverColor: coverColor,
      );
      emit(BoardCreated());
      await fetchBoardData(userUid, '');
    } catch (e) {
      emit(BoardError(message: AppExceptionMapper.map(e)));
    }
  }

  Future<void> refreshBoardData() async {
    final userUid = await userLocalDataSource.getUserId();

    if (userUid == null || userUid.isEmpty) {
      emit(
        const BoardError(
          message: 'Không tìm thấy tài khoản. Vui lòng đăng nhập lại.',
        ),
      );
      return;
    }

    await fetchBoardData(userUid, '', showLoading: false);
  }

  Future<bool> setBoardStarred({
    required String boardId,
    required bool isStarred,
  }) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      if (userUid.isEmpty) return false;
      await setBoardStarredUseCase(
        userUid: userUid,
        boardId: boardId,
        isStarred: isStarred,
      );
      await fetchBoardData(userUid, '', showLoading: false);
      return true;
    } catch (e) {
      emit(BoardError(message: AppExceptionMapper.map(e)));
      return false;
    }
  }

  Future<bool> renameBoard({
    required String boardId,
    required String boardName,
    String? visibility,
    String? workspaceUId,
  }) async {
    try {
      final userUid = await userLocalDataSource.getUserId() ?? '';
      if (userUid.isEmpty || boardName.trim().isEmpty) return false;
      await updateBoardUseCase(
        boardId: boardId,
        boardName: boardName.trim(),
        userUId: userUid,
        visibility: visibility,
        workspaceUId: workspaceUId,
      );
      await fetchBoardData(userUid, '', showLoading: false);
      return true;
    } catch (e) {
      emit(BoardError(message: AppExceptionMapper.map(e)));
      return false;
    }
  }
}
