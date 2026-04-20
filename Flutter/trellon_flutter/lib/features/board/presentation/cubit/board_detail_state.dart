import 'package:equatable/equatable.dart';
import '../../data/models/list_model.dart';
import '../../../card/domain/entities/card_entity.dart';

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
  final List<ListEntityData> lists;

  const BoardDetailLoaded({
    required this.boardId,
    required this.boardName,
    this.backgroundUrl,
    required this.lists,
  });

  @override
  List<Object?> get props => [boardId, boardName, backgroundUrl, lists];

  BoardDetailLoaded copyWith({
    List<ListEntityData>? lists,
    String? backgroundUrl,
  }) {
    return BoardDetailLoaded(
      boardId: boardId,
      boardName: boardName,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      lists: lists ?? this.lists,
    );
  }
}

class BoardDetailError extends BoardDetailState {
  final String message;

  const BoardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
