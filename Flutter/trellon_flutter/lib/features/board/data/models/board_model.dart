import '../../domain/entities/board_entity.dart';

class BoardModel extends BoardEntity {
  const BoardModel({
    required super.id,
    required super.name,
    required super.visibility,
    required super.isPersonal,
    super.workspaceId,
    required super.workspaceName,
    super.coverColor,
    super.status,
    super.backgroundUrl,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['boardUId'] ?? json['id'] ?? '',
      name: json['boardName'] ?? json['name'] ?? '',
      visibility: json['visibility'] ?? 'Private',
      isPersonal: json['isPersonal'] ?? false,
      workspaceId: json['workspaceUId'] ?? json['workspaceId'],
      workspaceName: json['workspaceName'] ?? 'Không gian làm việc',
      status: json['status'] ?? 'Active',
      backgroundUrl: json['backgroundUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boardUId': id,
      'boardName': name,
      'visibility': visibility,
      'isPersonal': isPersonal,
      'workspaceUId': workspaceId,
      'status': status,
      'backgroundUrl': backgroundUrl,
    };
  }
}
