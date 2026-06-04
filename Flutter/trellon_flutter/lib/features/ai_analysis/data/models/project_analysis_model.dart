import '../../domain/entities/project_analysis_entity.dart';

class ProjectAnalysisModel extends ProjectAnalysisEntity {
  const ProjectAnalysisModel({
    required super.scopeType,
    required super.scopeUId,
    required super.title,
    required super.overallProgress,
    required super.summary,
    super.risks,
    super.suggestions,
    super.metrics,
    super.breakdown,
    super.inferredMilestones,
    super.generatedAt,
    required super.model,
    super.cached,
    super.isGeminiSuccess,
  });

  factory ProjectAnalysisModel.fromJson(Map<String, dynamic> json) {
    return ProjectAnalysisModel(
      scopeType: _string(json['scopeType']),
      scopeUId: _string(json['scopeUId']),
      title: _string(json['title']),
      overallProgress: _int(json['overallProgress']).clamp(0, 100).toInt(),
      summary: _string(json['summary']),
      risks: _list(
        json['risks'],
      ).map((item) => ProjectAnalysisRiskModel.fromJson(item)).toList(),
      suggestions: _list(
        json['suggestions'],
      ).map((item) => ProjectAnalysisSuggestionModel.fromJson(item)).toList(),
      metrics: ProjectAnalysisMetricsModel.fromJson(_map(json['metrics'])),
      breakdown: _list(
        json['breakdown'],
      ).map((item) => ProjectAnalysisBreakdownModel.fromJson(item)).toList(),
      inferredMilestones: _list(
        json['inferredMilestones'],
      ).map((item) => ProjectAnalysisMilestoneModel.fromJson(item)).toList(),
      generatedAt: _date(json['generatedAt']),
      model: _string(json['model']),
      cached: json['cached'] == true,
      isGeminiSuccess: json['isGeminiSuccess'] != false,
    );
  }

  ProjectAnalysisEntity toEntity() => this;
}

class ProjectAnalysisRiskModel extends ProjectAnalysisRiskEntity {
  const ProjectAnalysisRiskModel({
    required super.title,
    required super.detail,
    required super.severity,
    super.relatedCardUIds,
  });

  factory ProjectAnalysisRiskModel.fromJson(Map<String, dynamic> json) {
    return ProjectAnalysisRiskModel(
      title: _string(json['title']),
      detail: _firstString(json, ['detail', 'description']),
      severity: _string(json['severity']),
      relatedCardUIds: _stringList(json['relatedCardUIds']),
    );
  }
}

class ProjectAnalysisSuggestionModel extends ProjectAnalysisSuggestionEntity {
  const ProjectAnalysisSuggestionModel({
    required super.title,
    required super.detail,
    required super.priority,
    required super.actionType,
  });

  factory ProjectAnalysisSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ProjectAnalysisSuggestionModel(
      title: _string(json['title']),
      detail: _firstString(json, ['detail', 'description']),
      priority: _string(json['priority']),
      actionType: _firstString(json, [
        'actionType',
      ], fallback: 'recommendation'),
    );
  }
}

class ProjectAnalysisMetricsModel extends ProjectAnalysisMetricsEntity {
  const ProjectAnalysisMetricsModel({
    super.totalCards,
    super.todoCards,
    super.inProgressCards,
    super.doneCards,
    super.overdueCards,
    super.dueSoonCards,
    super.blockedCards,
    super.otherCards,
    super.todoItems,
    super.doneTodoItems,
    super.statusDistribution,
  });

  factory ProjectAnalysisMetricsModel.fromJson(Map<String, dynamic> json) {
    return ProjectAnalysisMetricsModel(
      totalCards: _int(json['totalCards']),
      todoCards: _int(json['todoCards']),
      inProgressCards: _int(json['inProgressCards']),
      doneCards: _firstInt(json, ['doneCards', 'completedCards']),
      overdueCards: _int(json['overdueCards']),
      dueSoonCards: _int(json['dueSoonCards']),
      blockedCards: _int(json['blockedCards']),
      otherCards: _int(json['otherCards']),
      todoItems: _firstInt(json, ['todoItems', 'totalTodoItems']),
      doneTodoItems: _firstInt(json, ['doneTodoItems', 'completedTodoItems']),
      statusDistribution: _intMap(json['statusDistribution']),
    );
  }
}

class ProjectAnalysisBreakdownModel extends ProjectAnalysisBreakdownEntity {
  const ProjectAnalysisBreakdownModel({
    required super.name,
    required super.progress,
    required super.note,
  });

  factory ProjectAnalysisBreakdownModel.fromJson(Map<String, dynamic> json) {
    final progress = _firstInt(json, ['progress']);
    final totalCards = _int(json['totalCards']);
    final completedCards = _firstInt(json, ['doneCards', 'completedCards']);

    return ProjectAnalysisBreakdownModel(
      name: _firstString(json, ['label', 'name']),
      progress:
          (progress > 0
                  ? progress
                  : totalCards == 0
                  ? 0
                  : ((completedCards / totalCards) * 100).round())
              .clamp(0, 100)
              .toInt(),
      note: _firstString(json, ['note', 'description']),
    );
  }
}

class ProjectAnalysisMilestoneModel extends ProjectAnalysisMilestoneEntity {
  const ProjectAnalysisMilestoneModel({
    required super.title,
    super.dueDate,
    required super.status,
    required super.note,
  });

  factory ProjectAnalysisMilestoneModel.fromJson(Map<String, dynamic> json) {
    return ProjectAnalysisMilestoneModel(
      title: _firstString(json, ['title', 'name']),
      dueDate: _date(json['dueDate']),
      status: _string(json['status']),
      note: _firstString(json, ['note', 'description']),
    );
  }
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const {};
  return Map<String, int>.fromEntries(
    value.entries.map(
      (entry) => MapEntry(entry.key.toString(), _int(entry.value)),
    ),
  );
}

String _string(Object? value) => value?.toString() ?? '';

String _firstString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  return fallback;
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int _firstInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _int(json[key]);
    if (value != 0) return value;
  }
  return 0;
}

DateTime? _date(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
