import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:apptreolon/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:apptreolon/features/planner/presentation/cubit/planner_state.dart';
import 'package:apptreolon/features/planner/domain/usecases/get_planner_cards_usecase.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

class MockGetPlannerCardsUseCase extends Mock implements GetPlannerCardsUseCase {}

void main() {
  late PlannerCubit cubit;
  late MockGetPlannerCardsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetPlannerCardsUseCase();
    cubit = PlannerCubit(getPlannerCardsUseCase: mockUseCase);
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
}
