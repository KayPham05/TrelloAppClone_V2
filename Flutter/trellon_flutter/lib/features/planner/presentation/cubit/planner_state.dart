import '../../domain/entities/planner_entity.dart';

abstract class PlannerState {}

class PlannerInitial extends PlannerState {}

class PlannerLoading extends PlannerState {}

class PlannerLoaded extends PlannerState {
  final List<PlannerDayEntity> days;

  PlannerLoaded({required this.days});
}

class PlannerError extends PlannerState {
  final String message;

  PlannerError({required this.message});
}
