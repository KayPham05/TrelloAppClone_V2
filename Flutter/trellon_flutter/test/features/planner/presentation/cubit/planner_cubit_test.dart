import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:apptreolon/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:apptreolon/features/planner/presentation/cubit/planner_state.dart';
import 'package:apptreolon/features/planner/domain/usecases/get_planner_cards_usecase.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/card/domain/usecases/update_card_due_date_usecase.dart';
import 'package:apptreolon/core/data_sources/user_local_data_source.dart';

class MockGetPlannerCardsUseCase extends Mock implements GetPlannerCardsUseCase {}
class MockUpdateCardDueDateUseCase extends Mock implements UpdateCardDueDateUseCase {}
class MockUserLocalDataSource extends Mock implements UserLocalDataSource {}

void main() {
  late PlannerCubit cubit;
  late MockGetPlannerCardsUseCase mockUseCase;
  late MockUpdateCardDueDateUseCase mockUpdateUseCase;
  late MockUserLocalDataSource mockDataSource;

  setUp(() {
    mockUseCase = MockGetPlannerCardsUseCase();
    mockUpdateUseCase = MockUpdateCardDueDateUseCase();
    mockDataSource = MockUserLocalDataSource();
    cubit = PlannerCubit(
      getPlannerCardsUseCase: mockUseCase,
      updateCardDueDateUseCase: mockUpdateUseCase,
      userLocalDataSource: mockDataSource,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be PlannerInitial', () {
    expect(cubit.state, isA<PlannerInitial>());
  });

  blocTest<PlannerCubit, PlannerState>(
    'emits [PlannerLoading, PlannerLoaded] when loadMonth succeeds',
    build: () {
      when(() => mockUseCase.call(any(), any())).thenAnswer((_) async => <String, List<CardEntity>>{});
      return cubit;
    },
    act: (cubit) => cubit.loadMonth(DateTime(2023, 1, 15)),
    expect: () => [
      isA<PlannerLoading>(),
      isA<PlannerLoaded>(),
    ],
    verify: (_) {
      verify(() => mockUseCase.call(any(), any())).called(1);
    },
  );

  blocTest<PlannerCubit, PlannerState>(
    'emits [PlannerLoading, PlannerError] when loadMonth fails',
    build: () {
      when(() => mockUseCase.call(any(), any())).thenThrow(Exception('Failed to load'));
      return cubit;
    },
    act: (cubit) => cubit.loadMonth(DateTime(2023, 1, 15)),
    expect: () => [
      isA<PlannerLoading>(),
      isA<PlannerError>(),
    ],
  );

  blocTest<PlannerCubit, PlannerState>(
    'calls updateCardDueDateUseCase and reloads month on updateCardDate success',
    build: () {
      when(() => mockDataSource.getUserId()).thenAnswer((_) async => 'user-123');
      when(() => mockUpdateUseCase.call(
        cardId: any(named: 'cardId'),
        dueDate: any(named: 'dueDate'),
        userUId: any(named: 'userUId'),
      )).thenAnswer((_) async => const CardEntity(
        id: 'card-123',
        title: 'Test',
        position: 1,
      ));
      when(() => mockUseCase.call(any(), any())).thenAnswer((_) async => <String, List<CardEntity>>{});
      return cubit;
    },
    act: (cubit) => cubit.updateCardDate('card-123', DateTime(2023, 1, 20), DateTime(2023, 1, 15)),
    expect: () => [
      isA<PlannerLoading>(),
      isA<PlannerLoaded>(),
    ],
    verify: (_) {
      verify(() => mockDataSource.getUserId()).called(1);
      verify(() => mockUpdateUseCase.call(
        cardId: 'card-123',
        dueDate: DateTime(2023, 1, 20),
        userUId: 'user-123',
      )).called(1);
      verify(() => mockUseCase.call(any(), any())).called(1);
    },
  );

  blocTest<PlannerCubit, PlannerState>(
    'does not call updateCardDueDateUseCase if user is null',
    build: () {
      when(() => mockDataSource.getUserId()).thenAnswer((_) async => null);
      return cubit;
    },
    act: (cubit) => cubit.updateCardDate('card-123', DateTime(2023, 1, 20), DateTime(2023, 1, 15)),
    expect: () => [],
    verify: (_) {
      verify(() => mockDataSource.getUserId()).called(1);
      verifyNever(() => mockUpdateUseCase.call(
        cardId: any(named: 'cardId'),
        dueDate: any(named: 'dueDate'),
        userUId: any(named: 'userUId'),
      ));
    },
  );
}
