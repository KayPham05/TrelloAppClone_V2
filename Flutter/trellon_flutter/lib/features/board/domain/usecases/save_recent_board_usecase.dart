import '../repositories/board_repository.dart';

class SaveRecentBoardUseCase {
  final BoardRepository repository;

  SaveRecentBoardUseCase(this.repository);

  Future<void> call(String userUid, String boardId) async {
    return await repository.saveRecentBoard(userUid, boardId);
  }
}
