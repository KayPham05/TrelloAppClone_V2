import '../../../card/domain/entities/card_entity.dart';

// Entity mapped from C# Card.cs (DueDate field) for planner view
class PlannerDayEntity {
  final DateTime date;
  final List<CardEntity> cards;

  const PlannerDayEntity({
    required this.date,
    required this.cards,
  });

  bool get hasTask => cards.isNotEmpty;
}
