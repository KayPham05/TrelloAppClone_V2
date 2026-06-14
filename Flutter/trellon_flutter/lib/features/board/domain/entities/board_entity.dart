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
  final String? backgroundUrl;
  final bool isStarred;

  const BoardEntity({
    required this.id,
    required this.name,
    required this.visibility,
    required this.isPersonal,
    this.workspaceId,
    required this.workspaceName,
    this.coverColor,
    this.status = 'Active',
    this.backgroundUrl,
    this.isStarred = false,
  });

  BoardEntity copyWith({
    String? id,
    String? name,
    String? visibility,
    bool? isPersonal,
    String? workspaceId,
    String? workspaceName,
    String? coverColor,
    String? status,
    String? backgroundUrl,
    bool? isStarred,
  }) {
    return BoardEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      visibility: visibility ?? this.visibility,
      isPersonal: isPersonal ?? this.isPersonal,
      workspaceId: workspaceId ?? this.workspaceId,
      workspaceName: workspaceName ?? this.workspaceName,
      coverColor: coverColor ?? this.coverColor,
      status: status ?? this.status,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}
