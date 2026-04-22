import '../../domain/entities/workspace_entity.dart';
import '../../../board/data/models/board_model.dart';
import '../../../board/domain/entities/board_entity.dart';

class WorkspaceModel extends WorkspaceEntity {
  const WorkspaceModel({
    required super.id,
    required super.name,
    super.description,
    super.status,
    super.type,
    super.ownerUId,
    required super.boards,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    var boardsJson = json['boards'] as List?;
    List<BoardEntity> boardsList = boardsJson != null
        ? boardsJson.map((e) => BoardModel.fromJson(e)).toList()
        : [];

    return WorkspaceModel(
      id: json['workspaceUId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'Active',
      type: WorkspaceTypeExtension.fromString(json['type'] ?? 'personal'),
      ownerUId: json['ownerUId'],
      boards: boardsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspaceUId': id,
      'name': name,
      'description': description,
      'status': status,
      'type': type.toShortString(),
    };
  }
}
