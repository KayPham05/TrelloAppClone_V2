import '../../domain/entities/board_entity.dart';

abstract class BoardRepository {
  Future<List<BoardEntity>> getRecentBoards(String userUid);
  Future<List<BoardEntity>> getPersonalBoards(String userUid);
  Future<List<BoardEntity>> getAllBoards(String userUid);
  Future<void> createBoard({
    required String name,
    required String userUid,
    String? workspaceId,
    bool isPersonal = false,
    String? backgroundUrl,
    String? coverColor,
    String? visibility,
  });
  Future<void> saveRecentBoard(String userUid, String boardId);
  Future<void> deleteBoard(String boardId, String userUId);
  Future<List<dynamic>> getLists(String boardId);
  Future<String?> getUserRoleInBoard(String boardId, String userUId);
}

