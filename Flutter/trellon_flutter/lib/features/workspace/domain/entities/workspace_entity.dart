enum WorkspaceType { personal, team }

extension WorkspaceTypeExtension on WorkspaceType {
  String toShortString() => toString().split('.').last;
  
  static WorkspaceType fromString(String type) {
    if (type.toLowerCase() == 'team') return WorkspaceType.team;
    return WorkspaceType.personal;
  }
}

class WorkspaceEntity {
  final String id;
  final String name;
  final String? description;
  final String status;
  final WorkspaceType type;
  final String? ownerUId;
  final List<dynamic> boards; // Can be BoardEntity later

  const WorkspaceEntity({
    required this.id,
    required this.name,
    this.description,
    this.status = 'Active',
    this.type = WorkspaceType.personal,
    this.ownerUId,
    required this.boards,
  });

  WorkspaceEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    WorkspaceType? type,
    String? ownerUId,
    List<dynamic>? boards,
  }) {
    return WorkspaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      ownerUId: ownerUId ?? this.ownerUId,
      boards: boards ?? this.boards,
    );
  }
}
