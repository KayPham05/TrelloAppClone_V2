// Entity mapped from C# List.cs
import '../../../card/domain/entities/card_entity.dart';

class ListEntity {
  final String id;
  final String name;
  final int position;
  final String status;
  final String boardId;
  final List<CardEntity> cards;

  const ListEntity({
    required this.id,
    required this.name,
    required this.position,
    this.status = 'Active',
    required this.boardId,
    required this.cards,
  });
}
