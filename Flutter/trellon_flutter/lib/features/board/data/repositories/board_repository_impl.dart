import '../../domain/entities/board_entity.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/board_remote_data_source.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardRemoteDataSource remoteDataSource;

  BoardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BoardEntity>> getRecentBoards(String userUid) async {
    try {
      return await remoteDataSource.getRecentBoards(userUid);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<BoardEntity>> getAllBoards(String userUid) async {
    try {
      return await remoteDataSource.getAllBoards(userUid);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<BoardEntity>> getPersonalBoards(String userUid) async {
    try {
      final all = await remoteDataSource.getAllBoards(userUid);
      return all.where((b) => b.isPersonal).toList();
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<void> createBoard({
    required String name,
    required String userUid,
    String? workspaceId,
    bool isPersonal = false,
    String? backgroundUrl,
    String? coverColor,
    String? visibility,
  }) async {
    try {
      await remoteDataSource.createBoard(
        name: name,
        userUid: userUid,
        workspaceId: workspaceId,
        isPersonal: isPersonal,
        backgroundUrl: backgroundUrl,
        coverColor: coverColor,
        visibility: visibility,
      );
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<void> saveRecentBoard(String userUid, String boardId) async {
    try {
      await remoteDataSource.saveRecentBoard(userUid, boardId);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<List<dynamic>> getLists(String boardId) async {
    try {
      return await remoteDataSource.getLists(boardId);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<String?> getUserRoleInBoard(String boardId, String userUId) async {
    try {
      return await remoteDataSource.getUserRoleInBoard(boardId: boardId, userUId: userUId);
    } catch (e) {
      return null;
    }
  }
}
