import 'package:equatable/equatable.dart';

class ReportHistoryItemEntity extends Equatable {
  final String reportUId;
  final String scopeType;
  final String scopeUId;
  final String title;
  final int overallProgress;
  final String model;
  final DateTime? generatedAt;

  const ReportHistoryItemEntity({
    required this.reportUId,
    required this.scopeType,
    required this.scopeUId,
    required this.title,
    required this.overallProgress,
    required this.model,
    this.generatedAt,
  });

  @override
  List<Object?> get props => [
    reportUId,
    scopeType,
    scopeUId,
    title,
    overallProgress,
    model,
    generatedAt,
  ];
}
