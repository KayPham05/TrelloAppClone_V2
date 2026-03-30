// Entity mapped from C# Activity.cs
class ActivityEntity {
  final String id;
  final String action;
  final String cardTitle;
  final String userName;
  final DateTime createdAt;

  const ActivityEntity({
    required this.id,
    required this.action,
    required this.cardTitle,
    required this.userName,
    required this.createdAt,
  });
}
