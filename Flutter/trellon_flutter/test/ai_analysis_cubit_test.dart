import 'package:apptreolon/features/ai_analysis/domain/entities/project_analysis_entity.dart';
import 'package:apptreolon/features/ai_analysis/domain/entities/report_history_item_entity.dart';
import 'package:apptreolon/features/ai_analysis/domain/entities/report_history_page_entity.dart';
import 'package:apptreolon/features/ai_analysis/domain/repositories/i_ai_analysis_repository.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/analyze_board_usecase.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/analyze_card_usecase.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/analyze_workspace_usecase.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/get_report_by_id_usecase.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/get_report_history_usecase.dart';
import 'package:apptreolon/features/ai_analysis/domain/usecases/save_current_report_usecase.dart';
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
      getReportHistoryUseCase: GetReportHistoryUseCase(repository),
      getReportByIdUseCase: GetReportByIdUseCase(repository),
      saveCurrentReportUseCase: SaveCurrentReportUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'analyze emits loading then loaded for board scope',
    build: () {
      when(
        () => repository.analyzeBoard(boardUId: 'board-1', forceRefresh: false),
      ).thenAnswer((_) async => analysis);
      return cubit;
    },
    act: (cubit) => cubit.analyze(scopeType: 'board', scopeUId: 'board-1'),
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
        () => repository.analyzeBoard(boardUId: 'board-1', forceRefresh: false),
      ).thenThrow(Exception('Bạn không có quyền'));
      return cubit;
    },
    act: (cubit) => cubit.analyze(scopeType: 'board', scopeUId: 'board-1'),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisError>().having(
        (s) => s.message,
        'message',
        contains('Bạn không có quyền'),
      ),
    ],
  );

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'loadHistory emits loading then history loaded',
    build: () {
      when(
        () => repository.getReportHistory(
          scopeType: 'board',
          scopeUId: 'board-1',
          page: 1,
          pageSize: 5,
        ),
      ).thenAnswer(
        (_) async => ReportHistoryPageEntity(
          items: [
            ReportHistoryItemEntity(
              reportUId: 'report-1',
              scopeType: 'board',
              scopeUId: 'board-1',
              title: 'Board',
              overallProgress: 64,
              model: 'gemini-test',
              generatedAt: DateTime(2026, 6, 2),
            ),
          ],
          totalCount: 1,
          page: 1,
          pageSize: 5,
          hasMore: false,
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.loadHistory(scopeType: 'board', scopeUId: 'board-1'),
    expect: () => [
      isA<AiAnalysisLoading>(),
      isA<AiAnalysisHistoryLoaded>()
          .having((s) => s.items.single.reportUId, 'reportUId', 'report-1')
          .having((s) => s.hasMore, 'hasMore', false),
    ],
  );

  blocTest<AiAnalysisCubit, AiAnalysisState>(
    'loadReport emits loading then loaded',
    build: () {
      when(
        () => repository.getReportById(reportUId: 'report-1'),
      ).thenAnswer((_) async => analysis);
      return cubit;
    },
    act: (cubit) => cubit.loadReport(reportUId: 'report-1'),
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
    'saveCurrentReport emits saving then saved',
    build: () {
      when(
        () => repository.saveCurrentReport(
          scopeType: 'board',
          scopeUId: 'board-1',
        ),
      ).thenAnswer(
        (_) async => ReportHistoryItemEntity(
          reportUId: 'report-1',
          scopeType: 'board',
          scopeUId: 'board-1',
          title: 'Board',
          overallProgress: 64,
          model: 'gemini-test',
          generatedAt: DateTime(2026, 6, 2),
        ),
      );
      return cubit;
    },
    act: (cubit) =>
        cubit.saveCurrentReport(scopeType: 'board', scopeUId: 'board-1'),
    expect: () => [
      isA<AiAnalysisSaving>(),
      isA<AiAnalysisSaved>().having(
        (s) => s.report.reportUId,
        'reportUId',
        'report-1',
      ),
    ],
  );
}
