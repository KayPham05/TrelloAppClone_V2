import '../../../card/domain/entities/card_entity.dart';

abstract class PlannerRepository {
  Future<Map<String, List<CardEntity>>> getPlannerCards(DateTime from, DateTime to);
}
