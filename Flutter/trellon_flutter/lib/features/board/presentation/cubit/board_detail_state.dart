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
  final List<ListEntity> lists;
  final String? transientError;

  const BoardDetailLoaded({
    required this.boardId,
    required this.boardName,
    required this.lists,
    this.transientError,
  });

  BoardDetailLoaded copyWith({
    String? boardId,
    String? boardName,
    List<ListEntity>? lists,
    String? transientError,
    bool clearTransientError = false,
  }) {
    return BoardDetailLoaded(
      boardId: boardId ?? this.boardId,
      boardName: boardName ?? this.boardName,
      lists: lists ?? this.lists,
      transientError: clearTransientError ? null : (transientError ?? this.transientError),
    );
  }

  @override
  List<Object?> get props => [boardId, boardName, lists, transientError];
}

class BoardDetailError extends BoardDetailState {
  final String message;
  const BoardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
