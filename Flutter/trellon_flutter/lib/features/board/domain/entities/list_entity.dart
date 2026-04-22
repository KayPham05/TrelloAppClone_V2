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

  ListEntity copyWith({
    String? id,
    String? name,
    int? position,
    String? status,
    String? boardId,
    List<CardEntity>? cards,
  }) {
    return ListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      status: status ?? this.status,
      boardId: boardId ?? this.boardId,
      cards: cards ?? this.cards,
    );
  }
}
