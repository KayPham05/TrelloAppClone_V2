// Entity mapped from C# Board.cs
class BoardEntity {
  final String id;
  final String name;
  final String visibility;
  final bool isPersonal;
  final String? workspaceId;
  final String workspaceName;
  final String? coverColor; // hex color string for UI
  final String status;

  const BoardEntity({
    required this.id,
    required this.name,
    required this.visibility,
    required this.isPersonal,
    this.workspaceId,
    required this.workspaceName,
    this.coverColor,
    this.status = 'Active',
  });
}
