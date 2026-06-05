import 'package:apptreolon/features/ai_analysis/data/datasources/ai_analysis_remote_data_source.dart';
import 'package:apptreolon/features/ai_analysis/data/models/project_analysis_model.dart';
import 'package:apptreolon/features/ai_analysis/data/models/report_history_item_model.dart';
import 'package:apptreolon/features/ai_analysis/data/repositories/ai_analysis_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeAiAnalysisRemoteDataSource remoteDataSource;
  late AiAnalysisRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _FakeAiAnalysisRemoteDataSource();
    repository = AiAnalysisRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  test('analyzeWorkspace returns entity from remote model', () async {
    final result = await repository.analyzeWorkspace(
      workspaceUId: 'workspace-1',
      forceRefresh: true,
    );

    expect(result.scopeType, 'workspace');
    expect(result.scopeUId, 'workspace-1');
    expect(remoteDataSource.lastCall, 'analyzeWorkspace');
    expect(remoteDataSource.lastScopeUId, 'workspace-1');
    expect(remoteDataSource.lastForceRefresh, true);
  });

  test('analyzeBoard delegates board id and force refresh', () async {
    final result = await repository.analyzeBoard(
      boardUId: 'board-1',
      forceRefresh: true,
    );

    expect(result.scopeType, 'board');
    expect(result.scopeUId, 'board-1');
    expect(remoteDataSource.lastCall, 'analyzeBoard');
    expect(remoteDataSource.lastScopeUId, 'board-1');
    expect(remoteDataSource.lastForceRefresh, true);
  });

  test('analyzeCard delegates card id with default refresh flag', () async {
    final result = await repository.analyzeCard(cardUId: 'card-1');

    expect(result.scopeType, 'card');
    expect(result.scopeUId, 'card-1');
    expect(remoteDataSource.lastCall, 'analyzeCard');
    expect(remoteDataSource.lastScopeUId, 'card-1');
    expect(remoteDataSource.lastForceRefresh, false);
  });

  test('getReportHistory maps page model to entity', () async {
    final result = await repository.getReportHistory(
      scopeType: 'board',
      scopeUId: 'board-1',
      page: 2,
      pageSize: 10,
    );

    expect(result.items.single.reportUId, 'report-1');
    expect(result.totalCount, 1);
    expect(remoteDataSource.lastCall, 'getReportHistory');
    expect(remoteDataSource.lastScopeType, 'board');
    expect(remoteDataSource.lastScopeUId, 'board-1');
    expect(remoteDataSource.lastPage, 2);
    expect(remoteDataSource.lastPageSize, 10);
  });

  test('saveCurrentReport maps saved report model to entity', () async {
    final result = await repository.saveCurrentReport(
      scopeType: 'workspace',
      scopeUId: 'workspace-1',
    );

    expect(result.reportUId, 'saved-report');
    expect(result.scopeType, 'workspace');
    expect(remoteDataSource.lastCall, 'saveCurrentReport');
    expect(remoteDataSource.lastScopeType, 'workspace');
    expect(remoteDataSource.lastScopeUId, 'workspace-1');
  });

  test('getReportById maps remote model to entity', () async {
    final result = await repository.getReportById(reportUId: 'report-1');

    expect(result.scopeType, 'report');
    expect(result.scopeUId, 'report-1');
    expect(remoteDataSource.lastCall, 'getReportById');
    expect(remoteDataSource.lastReportUId, 'report-1');
  });
}

class _FakeAiAnalysisRemoteDataSource implements AiAnalysisRemoteDataSource {
  String? lastCall;
  String? lastScopeType;
  String? lastScopeUId;
  String? lastReportUId;
  bool? lastForceRefresh;
  int? lastPage;
  int? lastPageSize;

  @override
  Future<ProjectAnalysisModel> analyzeWorkspace({
    required String workspaceUId,
    bool forceRefresh = false,
  }) async {
    lastCall = 'analyzeWorkspace';
    lastScopeUId = workspaceUId;
    lastForceRefresh = forceRefresh;
    return _analysis(scopeType: 'workspace', scopeUId: workspaceUId);
  }

  @override
  Future<ProjectAnalysisModel> analyzeBoard({
    required String boardUId,
    bool forceRefresh = false,
  }) async {
    lastCall = 'analyzeBoard';
    lastScopeUId = boardUId;
    lastForceRefresh = forceRefresh;
    return _analysis(scopeType: 'board', scopeUId: boardUId);
  }

  @override
  Future<ProjectAnalysisModel> analyzeCard({
    required String cardUId,
    bool forceRefresh = false,
  }) async {
    lastCall = 'analyzeCard';
    lastScopeUId = cardUId;
    lastForceRefresh = forceRefresh;
    return _analysis(scopeType: 'card', scopeUId: cardUId);
  }

  @override
  Future<ReportHistoryPageModel> getReportHistory({
    required String scopeType,
    required String scopeUId,
    int page = 1,
    int pageSize = 5,
  }) async {
    lastCall = 'getReportHistory';
    lastScopeType = scopeType;
    lastScopeUId = scopeUId;
    lastPage = page;
    lastPageSize = pageSize;
    return ReportHistoryPageModel(
      items: [
        _historyItem(
          reportUId: 'report-1',
          scopeType: scopeType,
          scopeUId: scopeUId,
        ),
      ],
      totalCount: 1,
      page: page,
      pageSize: pageSize,
      hasMore: false,
    );
  }

  @override
  Future<ReportHistoryItemModel> saveCurrentReport({
    required String scopeType,
    required String scopeUId,
  }) async {
    lastCall = 'saveCurrentReport';
    lastScopeType = scopeType;
    lastScopeUId = scopeUId;
    return _historyItem(
      reportUId: 'saved-report',
      scopeType: scopeType,
      scopeUId: scopeUId,
    );
  }

  @override
  Future<ProjectAnalysisModel> getReportById({
    required String reportUId,
  }) async {
    lastCall = 'getReportById';
    lastReportUId = reportUId;
    return _analysis(scopeType: 'report', scopeUId: reportUId);
  }
}

ProjectAnalysisModel _analysis({
  required String scopeType,
  required String scopeUId,
}) {
  return ProjectAnalysisModel(
    scopeType: scopeType,
    scopeUId: scopeUId,
    title: 'Analysis $scopeUId',
    overallProgress: 72,
    summary: 'Summary',
    model: 'gemini-test',
  );
}

ReportHistoryItemModel _historyItem({
  required String reportUId,
  required String scopeType,
  required String scopeUId,
}) {
  return ReportHistoryItemModel(
    reportUId: reportUId,
    scopeType: scopeType,
    scopeUId: scopeUId,
    title: 'Report $reportUId',
    overallProgress: 72,
    model: 'gemini-test',
  );
}
