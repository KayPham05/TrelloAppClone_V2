// Entity mapped from C# Workspace.cs
import 'board_entity.dart';

class WorkspaceEntity {
  final String id;
  final String name;
  final String? description;
  final String status;
  final List<BoardEntity> boards;

  const WorkspaceEntity({
    required this.id,
    required this.name,
    this.description,
    this.status = 'Active',
    required this.boards,
  });
}
