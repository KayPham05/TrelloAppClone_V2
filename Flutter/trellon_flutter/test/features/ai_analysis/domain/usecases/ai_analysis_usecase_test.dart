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
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeAiAnalysisRepository repository;

  setUp(() {
    repository = _FakeAiAnalysisRepository();
  });

  test('AnalyzeWorkspaceUseCase delegates workspace arguments', () async {
    final useCase = AnalyzeWorkspaceUseCase(repository);

    final result = await useCase(
      workspaceUId: 'workspace-1',
      forceRefresh: true,
    );

    expect(result.scopeType, 'workspace');
    expect(repository.lastCall, 'analyzeWorkspace');
    expect(repository.lastScopeUId, 'workspace-1');
    expect(repository.lastForceRefresh, true);
  });

  test('AnalyzeBoardUseCase delegates board arguments', () async {
    final useCase = AnalyzeBoardUseCase(repository);

    final result = await useCase(boardUId: 'board-1', forceRefresh: true);

    expect(result.scopeType, 'board');
    expect(repository.lastCall, 'analyzeBoard');
    expect(repository.lastScopeUId, 'board-1');
    expect(repository.lastForceRefresh, true);
  });

  test('AnalyzeCardUseCase delegates default force refresh', () async {
    final useCase = AnalyzeCardUseCase(repository);

    final result = await useCase(cardUId: 'card-1');

    expect(result.scopeType, 'card');
    expect(repository.lastCall, 'analyzeCard');
    expect(repository.lastScopeUId, 'card-1');
    expect(repository.lastForceRefresh, false);
  });

  test('GetReportHistoryUseCase delegates paging arguments', () async {
    final useCase = GetReportHistoryUseCase(repository);

    final result = await useCase(
      scopeType: 'board',
      scopeUId: 'board-1',
      page: 3,
      pageSize: 20,
    );

    expect(result.page, 3);
    expect(result.pageSize, 20);
    expect(repository.lastCall, 'getReportHistory');
    expect(repository.lastScopeType, 'board');
    expect(repository.lastScopeUId, 'board-1');
  });

  test('SaveCurrentReportUseCase delegates scope arguments', () async {
    final useCase = SaveCurrentReportUseCase(repository);

    final result = await useCase(scopeType: 'card', scopeUId: 'card-1');

    expect(result.reportUId, 'saved-report');
    expect(repository.lastCall, 'saveCurrentReport');
    expect(repository.lastScopeType, 'card');
    expect(repository.lastScopeUId, 'card-1');
  });

  test('GetReportByIdUseCase delegates report id', () async {
    final useCase = GetReportByIdUseCase(repository);

    final result = await useCase(reportUId: 'report-1');

    expect(result.scopeUId, 'report-1');
    expect(repository.lastCall, 'getReportById');
    expect(repository.lastReportUId, 'report-1');
  });
}

class _FakeAiAnalysisRepository implements IAiAnalysisRepository {
  String? lastCall;
  String? lastScopeType;
  String? lastScopeUId;
  String? lastReportUId;
  bool? lastForceRefresh;

  @override
  Future<ProjectAnalysisEntity> analyzeWorkspace({
    required String workspaceUId,
    bool forceRefresh = false,
  }) async {
    lastCall = 'analyzeWorkspace';
    lastScopeUId = workspaceUId;
    lastForceRefresh = forceRefresh;
    return _analysis(scopeType: 'workspace', scopeUId: workspaceUId);
  }

  @override
  Future<ProjectAnalysisEntity> analyzeBoard({
    required String boardUId,
    bool forceRefresh = false,
  }) async {
    lastCall = 'analyzeBoard';
    lastScopeUId = boardUId;
    lastForceRefresh = forceRefresh;
    return _analysis(scopeType: 'board', scopeUId: boardUId);
  }

  @override
  Future<ProjectAnalysisEntity> analyzeCard({
    required String cardUId,
    bool forceRefresh = false,
  }) async {
    lastCall = 'analyzeCard';
    lastScopeUId = cardUId;
    lastForceRefresh = forceRefresh;
    return _analysis(scopeType: 'card', scopeUId: cardUId);
  }

  @override
  Future<ReportHistoryPageEntity> getReportHistory({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  }) async {
    lastCall = 'getReportHistory';
    lastScopeType = scopeType;
    lastScopeUId = scopeUId;
    return ReportHistoryPageEntity(
      items: const [],
      totalCount: 0,
      page: page,
      pageSize: pageSize,
      hasMore: false,
    );
  }

  @override
  Future<ReportHistoryItemEntity> saveCurrentReport({
    required String scopeType,
    required String scopeUId,
  }) async {
    lastCall = 'saveCurrentReport';
    lastScopeType = scopeType;
    lastScopeUId = scopeUId;
    return ReportHistoryItemEntity(
      reportUId: 'saved-report',
      scopeType: scopeType,
      scopeUId: scopeUId,
      title: 'Saved report',
      overallProgress: 80,
      model: 'gemini-test',
    );
  }

  @override
  Future<ProjectAnalysisEntity> getReportById({
    required String reportUId,
  }) async {
    lastCall = 'getReportById';
    lastReportUId = reportUId;
    return _analysis(scopeType: 'report', scopeUId: reportUId);
  }
}

ProjectAnalysisEntity _analysis({
  required String scopeType,
  required String scopeUId,
}) {
  return ProjectAnalysisEntity(
    scopeType: scopeType,
    scopeUId: scopeUId,
    title: 'Analysis $scopeUId',
    overallProgress: 80,
    summary: 'Summary',
    model: 'gemini-test',
  );
}
