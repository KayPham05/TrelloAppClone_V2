import 'package:apptreolon/features/ai_analysis/data/models/project_analysis_model.dart';
import 'package:apptreolon/features/ai_analysis/data/models/report_history_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectAnalysisModel.fromJson', () {
    test('parses full response payload', () {
      final model = ProjectAnalysisModel.fromJson({
        'scopeType': 'board',
        'scopeUId': 'board-1',
        'title': 'Sprint Board',
        'overallProgress': 64,
        'summary': 'Board đang ổn.',
        'risks': [
          {
            'severity': 'high',
            'title': 'Quá hạn',
            'description': 'Có card quá hạn.',
            'relatedCardUIds': ['card-1'],
          },
        ],
        'suggestions': [
          {
            'priority': 'high',
            'title': 'Ưu tiên bug',
            'description': 'Xử lý bug trước.',
          },
        ],
        'metrics': {
          'totalCards': 12,
          'completedCards': 5,
          'overdueCards': 2,
          'totalTodoItems': 30,
          'completedTodoItems': 18,
        },
        'breakdown': [
          {
            'name': 'Doing',
            'totalCards': 4,
            'completedCards': 1,
            'overdueCards': 2,
          },
        ],
        'inferredMilestones': [
          {
            'name': 'Hoàn tất checklist',
            'status': 'atRisk',
            'description': 'Checklist còn thiếu.',
          },
        ],
        'generatedAt': '2026-06-02T00:00:00Z',
        'model': 'gemini-test',
        'cached': true,
      });

      expect(model.scopeType, 'board');
      expect(model.overallProgress, 64);
      expect(model.risks.single.relatedCardUIds, ['card-1']);
      expect(model.suggestions.single.priority, 'high');
      expect(model.metrics.totalCards, 12);
      expect(model.breakdown.single.name, 'Doing');
      expect(model.inferredMilestones.single.status, 'atRisk');
      expect(model.cached, true);
    });

    test('maps missing arrays to empty lists and clamps progress', () {
      final model = ProjectAnalysisModel.fromJson({
        'scopeType': 'board',
        'scopeUId': 'board-1',
        'title': 'Board',
        'overallProgress': 180,
        'summary': 'Fallback',
        'metrics': {},
      });

      expect(model.overallProgress, 100);
      expect(model.risks, isEmpty);
      expect(model.suggestions, isEmpty);
      expect(model.breakdown, isEmpty);
      expect(model.inferredMilestones, isEmpty);
      expect(model.metrics.totalCards, 0);
    });
  });

  group('ReportHistoryPageModel.fromJson', () {
    test('parses history page payload', () {
      final model = ReportHistoryPageModel.fromJson({
        'items': [
          {
            'reportUId': 'report-1',
            'scopeType': 'board',
            'scopeUId': 'board-1',
            'title': 'Sprint Board',
            'overallProgress': 64,
            'model': 'gemini-test',
            'generatedAt': '2026-06-02T00:00:00Z',
          },
        ],
        'totalCount': 6,
        'page': 1,
        'pageSize': 5,
        'hasMore': true,
      });

      expect(model.items.single.reportUId, 'report-1');
      expect(model.items.single.scopeType, 'board');
      expect(model.items.single.overallProgress, 64);
      expect(model.totalCount, 6);
      expect(model.hasMore, true);
    });

    test('maps missing items to empty list', () {
      final model = ReportHistoryPageModel.fromJson({
        'totalCount': 0,
        'page': 1,
        'pageSize': 5,
        'hasMore': false,
      });

      expect(model.items, isEmpty);
      expect(model.hasMore, false);
    });
  });
}
