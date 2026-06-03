import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/features/planner/domain/repositories/planner_repository.dart';
import 'package:apptreolon/features/planner/domain/usecases/get_planner_cards_usecase.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

class MockPlannerRepository extends Mock implements PlannerRepository {}

void main() {
  late GetPlannerCardsUseCase useCase;
  late MockPlannerRepository mockRepository;

  setUp(() {
    mockRepository = MockPlannerRepository();
    useCase = GetPlannerCardsUseCase(mockRepository);
  });

  test('should get planner cards from repository', () async {
    // Arrange
    final from = DateTime(2023, 1, 1);
    final to = DateTime(2023, 1, 31);
    final expectedCards = {
      '2023-01-15': <CardEntity>[],
    };

    when(() => mockRepository.getPlannerCards(from, to))
        .thenAnswer((_) async => expectedCards);

    // Act
    final result = await useCase(from, to);

    // Assert
    expect(result, equals(expectedCards));
    verify(() => mockRepository.getPlannerCards(from, to)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
