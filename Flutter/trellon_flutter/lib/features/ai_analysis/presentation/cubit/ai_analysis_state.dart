import 'package:equatable/equatable.dart';

import '../../domain/entities/project_analysis_entity.dart';

abstract class AiAnalysisState extends Equatable {
  const AiAnalysisState();

  @override
  List<Object?> get props => [];
}

class AiAnalysisInitial extends AiAnalysisState {
  const AiAnalysisInitial();
}

class AiAnalysisLoading extends AiAnalysisState {
  const AiAnalysisLoading();
}

class AiAnalysisLoaded extends AiAnalysisState {
  final ProjectAnalysisEntity analysis;

  const AiAnalysisLoaded(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class AiAnalysisError extends AiAnalysisState {
  final String message;

  const AiAnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
