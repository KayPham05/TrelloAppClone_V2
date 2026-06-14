import '../../domain/entities/board_entity.dart';

abstract class BoardRepository {
  Future<List<BoardEntity>> getRecentBoards(String userUid);
  Future<List<BoardEntity>> getStarredBoards(String userUid);
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
  Future<void> setBoardStarred({
    required String userUid,
    required String boardId,
    required bool isStarred,
  });
  Future<void> updateBoard({
    required String boardId,
    required String boardName,
    required String userUId,
    String? backgroundUrl,
    String? visibility,
    String? workspaceUId,
  });
  Future<void> deleteBoard(String boardId, String userUId);
  Future<List<dynamic>> getLists(String boardId);
  Future<String?> getUserRoleInBoard(String boardId, String userUId);
}
