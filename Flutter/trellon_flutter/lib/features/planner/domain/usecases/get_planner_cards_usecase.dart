import '../repositories/planner_repository.dart';
import '../../../card/domain/entities/card_entity.dart';

class GetPlannerCardsUseCase {
  final PlannerRepository repository;

  GetPlannerCardsUseCase(this.repository);

  Future<Map<String, List<CardEntity>>> call(DateTime from, DateTime to) {
    return repository.getPlannerCards(from, to);
  }
}
