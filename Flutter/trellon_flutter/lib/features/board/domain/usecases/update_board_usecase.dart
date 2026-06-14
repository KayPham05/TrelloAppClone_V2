import '../repositories/board_repository.dart';

class UpdateBoardUseCase {
  final BoardRepository repository;

  UpdateBoardUseCase(this.repository);

  Future<void> call({
    required String boardId,
    required String boardName,
    required String userUId,
    String? backgroundUrl,
    String? visibility,
    String? workspaceUId,
  }) async {
    await repository.updateBoard(
      boardId: boardId,
      boardName: boardName,
      userUId: userUId,
      backgroundUrl: backgroundUrl,
      visibility: visibility,
      workspaceUId: workspaceUId,
    );
  }
}
