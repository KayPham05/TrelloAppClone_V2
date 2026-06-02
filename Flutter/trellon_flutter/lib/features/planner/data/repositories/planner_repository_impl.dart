import '../../domain/repositories/planner_repository.dart';
import '../datasources/planner_remote_data_source.dart';
import '../../../card/domain/entities/card_entity.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerRemoteDataSource remoteDataSource;

  PlannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, List<CardEntity>>> getPlannerCards(DateTime from, DateTime to) async {
    final Map<String, List<CardEntity>> result = {};
    try {
      final cardsMap = await remoteDataSource.getPlannerCards(from, to);
      cardsMap.forEach((key, value) {
        result[key] = value.map((model) => model.toEntity()).toList();
      });
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
