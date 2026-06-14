import '../repositories/board_repository.dart';

class SetBoardStarredUseCase {
  final BoardRepository repository;

  SetBoardStarredUseCase(this.repository);

  Future<void> call({
    required String userUid,
    required String boardId,
    required bool isStarred,
  }) async {
    await repository.setBoardStarred(
      userUid: userUid,
      boardId: boardId,
      isStarred: isStarred,
    );
  }
}
