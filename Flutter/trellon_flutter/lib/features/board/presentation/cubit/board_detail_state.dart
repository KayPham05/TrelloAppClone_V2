import 'package:equatable/equatable.dart';
import '../../domain/entities/list_entity.dart';
import 'board_filter_cubit.dart';

abstract class BoardDetailState extends Equatable {
  const BoardDetailState();

  @override
  List<Object?> get props => [];
}

class BoardDetailInitial extends BoardDetailState {}

class BoardDetailLoading extends BoardDetailState {}

class BoardDetailLoaded extends BoardDetailState {
  final String boardId;
  final String boardName;
  final String? backgroundUrl;
  final List<ListEntity> lists;
  final String? transientError;
  final String? boardRole;
  final String? workspaceRole;
  final String? boardVisibility;
  final String? workspaceId;
  final String? workspaceName;
  final bool isPersonal;
  final List<ListEntity>? unfilteredLists;
  final BoardFilterState activeFilter;
  final bool isFiltering;
  final String? filterError;

  const BoardDetailLoaded({
    required this.boardId,
    required this.boardName,
    this.backgroundUrl,
    required this.lists,
    this.transientError,
    this.boardRole,
    this.workspaceRole,
    this.boardVisibility,
    this.workspaceId,
    this.workspaceName,
    this.isPersonal = false,
    this.unfilteredLists,
    this.activeFilter = const BoardFilterState(),
    this.isFiltering = false,
    this.filterError,
  });

  BoardDetailLoaded copyWith({
    String? boardId,
    String? boardName,
    String? backgroundUrl,
    List<ListEntity>? lists,
    String? transientError,
    bool clearTransientError = false,
    String? boardRole,
    String? workspaceRole,
    String? boardVisibility,
    String? workspaceId,
    String? workspaceName,
    bool? isPersonal,
    List<ListEntity>? unfilteredLists,
    BoardFilterState? activeFilter,
    bool? isFiltering,
    String? filterError,
    bool clearFilterError = false,
  }) {
    return BoardDetailLoaded(
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      lists: lists ?? this.lists,
      transientError: clearTransientError
          ? null
          : (transientError ?? this.transientError),
      boardRole: boardRole ?? this.boardRole,
      workspaceRole: workspaceRole ?? this.workspaceRole,
      boardVisibility: boardVisibility ?? this.boardVisibility,
      workspaceId: workspaceId ?? this.workspaceId,
      workspaceName: workspaceName ?? this.workspaceName,
      isPersonal: isPersonal ?? this.isPersonal,
      unfilteredLists: unfilteredLists ?? this.unfilteredLists,
      activeFilter: activeFilter ?? this.activeFilter,
      isFiltering: isFiltering ?? this.isFiltering,
      filterError: clearFilterError ? null : (filterError ?? this.filterError),
    );
  }

  @override
  List<Object?> get props => [
        boardId,
        boardName,
        backgroundUrl,
        lists,
        transientError,
        boardRole,
        workspaceRole,
        boardVisibility,
        workspaceId,
        workspaceName,
        isPersonal,
        unfilteredLists,
        activeFilter,
        isFiltering,
        filterError,
      ];
}

class BoardDetailError extends BoardDetailState {
  final String message;
  const BoardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
