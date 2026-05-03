import 'package:equatable/equatable.dart';
import '../../domain/entities/list_entity.dart';

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
  }) {
    return BoardDetailLoaded(
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      lists: lists ?? this.lists,
      transientError: clearTransientError ? null : (transientError ?? this.transientError),
      boardRole: boardRole ?? this.boardRole,
      workspaceRole: workspaceRole ?? this.workspaceRole,
      boardVisibility: boardVisibility ?? this.boardVisibility,
      workspaceId: workspaceId ?? this.workspaceId,
      workspaceName: workspaceName ?? this.workspaceName,
    );
  }

  @override
  List<Object?> get props => [boardId, boardName, backgroundUrl, lists, transientError, boardRole, workspaceRole, boardVisibility, workspaceId, workspaceName];
}

class BoardDetailError extends BoardDetailState {
  final String message;
  const BoardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
