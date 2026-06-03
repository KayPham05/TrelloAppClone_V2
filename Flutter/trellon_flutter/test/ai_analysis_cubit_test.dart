import 'package:apptreolon/features/ai_analysis/domain/entities/project_analysis_entity.dart';
import 'package:apptreolon/features/ai_analysis/domain/repositories/i_ai_analysis_repository.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/analyze_board_usecase.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/analyze_card_usecase.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/analyze_workspace_usecase.dart';
import 'package:apptreolon/features/ai_analysis/presentation/cubit/ai_analysis_cubit.dart';
import 'package:apptreolon/features/ai_analysis/presentation/cubit/ai_analysis_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAiAnalysisRepository extends Mock implements IAiAnalysisRepository {}

void main() {
  late MockAiAnalysisRepository repository;
  late AiAnalysisCubit cubit;

  final analysis = ProjectAnalysisEntity(
    scopeType: 'board',
    scopeUId: 'board-1',
    title: 'Board',
    overallProgress: 64,
    summary: 'Board ổn.',
    generatedAt: DateTime(2026, 6, 2),
    model: 'gemini-test',
  );

  setUp(() {
    repository = MockAiAnalysisRepository();
    cubit = AiAnalysisCubit(
      analyzeWorkspaceUseCase: AnalyzeWorkspaceUseCase(repository),
      analyzeBoardUseCase: AnalyzeBoardUseCase(repository),
      analyzeCardUseCase: AnalyzeCardUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'analyze emits loading then loaded for board scope',
    build: () {
      when(
        () => repository.analyzeBoard(boardUId: 'board-1', userUId: 'user-1'),
      ).thenAnswer((_) async => analysis);
      return cubit;
    },
    act: (cubit) => cubit.analyze(
      scopeType: 'board',
      scopeUId: 'board-1',
      userUId: 'user-1',
    ),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisLoaded>().having(
        (s) => s.analysis.scopeUId,
        'scopeUId',
        'board-1',
      ),
    ],
  );

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'analyze emits error when repository throws',
    build: () {
      when(
        () => repository.analyzeBoard(boardUId: 'board-1', userUId: 'viewer'),
      ).thenThrow(Exception('Bạn không có quyền'));
      return cubit;
    },
    act: (cubit) => cubit.analyze(
      scopeType: 'board',
      scopeUId: 'board-1',
      userUId: 'viewer',
    ),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisError>().having(
        (s) => s.message,
        'message',
        contains('Bạn không có quyền'),
      ),
    ],
  );
}
