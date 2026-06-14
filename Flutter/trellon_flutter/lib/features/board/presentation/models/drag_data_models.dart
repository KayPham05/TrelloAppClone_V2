import '../../domain/entities/list_entity.dart';
import '../../../card/domain/entities/card_entity.dart';

abstract class BoardDragData {
  final String id;
  final String boardId;
  final int initialPosition;

  const BoardDragData({
    required this.id,
    required this.boardId,
    required this.initialPosition,
  });

  bool isValid(String currentBoardId) => boardId == currentBoardId;
}

class CardDragData extends BoardDragData {
  final String sourceListId;
  final CardEntity card;

  const CardDragData({
    required super.id,
    required super.boardId,
    required super.initialPosition,
    required this.sourceListId,
    required this.card,
  });
}

class ListDragData extends BoardDragData {
  final ListEntity list;

  const ListDragData({
    required super.id,
    required super.boardId,
    required super.initialPosition,
    required this.list,
  });
}
