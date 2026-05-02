import '../../../board/domain/entities/board_entity.dart';
import 'workspace_member.dart';

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
  final List<BoardEntity> boards;
  final List<WorkspaceMember>? members;

  const WorkspaceEntity({
    required this.id,
    required this.name,
    this.description,
    this.status = 'Active',
    this.type = WorkspaceType.personal,
    this.ownerUId,
    required this.boards,
    this.members,
  });

  WorkspaceEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    WorkspaceType? type,
    String? ownerUId,
    List<BoardEntity>? boards,
    List<WorkspaceMember>? members,
  }) {
    return WorkspaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      ownerUId: ownerUId ?? this.ownerUId,
      boards: boards ?? this.boards,
      members: members ?? this.members,
    );
  }
  String? getUserRole(String userUId) {
    if (members == null || members!.isEmpty) {
      return (userUId == ownerUId) ? 'Owner' : null;
    }
    try {
      final member = members!.firstWhere((m) => m.userUId == userUId);
      return member.role;
    } catch (_) {
      return (userUId == ownerUId) ? 'Owner' : null;
    }
  }
}
