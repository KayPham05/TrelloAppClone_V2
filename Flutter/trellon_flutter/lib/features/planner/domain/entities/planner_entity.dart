// Entity mapped from C# Card.cs (DueDate field) for planner view
class PlannerDayEntity {
  final DateTime date;
  final List<String> taskTitles;

  const PlannerDayEntity({
    required this.date,
    required this.taskTitles,
  });

  bool get hasTask => taskTitles.isNotEmpty;
}
