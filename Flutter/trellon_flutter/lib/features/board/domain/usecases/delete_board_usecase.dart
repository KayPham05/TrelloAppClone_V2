import '../repositories/board_repository.dart';

class DeleteBoardUseCase {
  final BoardRepository repository;

  DeleteBoardUseCase(this.repository);

  Future<void> call({required String boardId, required String userUId}) async {
    return await repository.deleteBoard(boardId, userUId);
  }
}
