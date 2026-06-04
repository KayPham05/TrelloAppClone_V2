import 'package:equatable/equatable.dart';

class ProjectAnalysisEntity extends Equatable {
  final String scopeType;
  final String scopeUId;
  final String title;
  final int overallProgress;
  final String summary;
  final List<ProjectAnalysisRiskEntity> risks;
  final List<ProjectAnalysisSuggestionEntity> suggestions;
  final ProjectAnalysisMetricsEntity metrics;
  final List<ProjectAnalysisBreakdownEntity> breakdown;
  final List<ProjectAnalysisMilestoneEntity> inferredMilestones;
  final DateTime? generatedAt;
  final String model;
  final bool cached;

  const ProjectAnalysisEntity({
    required this.scopeType,
    required this.scopeUId,
    required this.title,
    required this.overallProgress,
    required this.summary,
    this.risks = const [],
    this.suggestions = const [],
    this.metrics = const ProjectAnalysisMetricsEntity(),
    this.breakdown = const [],
    this.inferredMilestones = const [],
    this.generatedAt,
    required this.model,
    this.cached = false,
  });

  @override
  List<Object?> get props => [
    scopeType,
    scopeUId,
    title,
    overallProgress,
    summary,
    risks,
    suggestions,
    metrics,
    breakdown,
    inferredMilestones,
    generatedAt,
    model,
    cached,
  ];
}

class ProjectAnalysisRiskEntity extends Equatable {
  final String title;
  final String detail;
  final String severity;
  final List<String> relatedCardUIds;

  const ProjectAnalysisRiskEntity({
    required this.title,
    required this.detail,
    required this.severity,
    this.relatedCardUIds = const [],
  });

  @override
  List<Object?> get props => [title, detail, severity, relatedCardUIds];
}

class ProjectAnalysisSuggestionEntity extends Equatable {
  final String title;
  final String detail;
  final String priority;
  final String actionType;

  const ProjectAnalysisSuggestionEntity({
    required this.title,
    required this.detail,
    required this.priority,
    required this.actionType,
  });

  @override
  List<Object?> get props => [title, detail, priority, actionType];
}

class ProjectAnalysisMetricsEntity extends Equatable {
  final int totalCards;
  final int todoCards;
  final int inProgressCards;
  final int doneCards;
  final int overdueCards;
  final int dueSoonCards;
  final int blockedCards;
  final int otherCards;
  final int todoItems;
  final int doneTodoItems;
  final Map<String, int> statusDistribution;

  const ProjectAnalysisMetricsEntity({
    this.totalCards = 0,
    this.todoCards = 0,
    this.inProgressCards = 0,
    this.doneCards = 0,
    this.overdueCards = 0,
    this.dueSoonCards = 0,
    this.blockedCards = 0,
    this.otherCards = 0,
    this.todoItems = 0,
    this.doneTodoItems = 0,
    this.statusDistribution = const {},
  });

  @override
  List<Object?> get props => [
    totalCards,
    todoCards,
    inProgressCards,
    doneCards,
    overdueCards,
    dueSoonCards,
    blockedCards,
    otherCards,
    todoItems,
    doneTodoItems,
    statusDistribution,
  ];
}

class ProjectAnalysisBreakdownEntity extends Equatable {
  final String name;
  final int progress;
  final String note;

  const ProjectAnalysisBreakdownEntity({
    required this.name,
    required this.progress,
    required this.note,
  });

  String get label => name;

  @override
  List<Object?> get props => [name, progress, note];
}

class ProjectAnalysisMilestoneEntity extends Equatable {
  final String title;
  final DateTime? dueDate;
  final String status;
  final String note;

  const ProjectAnalysisMilestoneEntity({
    required this.title,
    this.dueDate,
    required this.status,
    required this.note,
  });

  @override
  List<Object?> get props => [title, dueDate, status, note];
}
