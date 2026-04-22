import '../repositories/board_repository.dart';

class CreateBoardUseCase {
  final BoardRepository repository;

  CreateBoardUseCase(this.repository);

  Future<void> call({
    required String name,
    required String userUid,
    String? workspaceId,
    bool isPersonal = false,
    String? backgroundUrl,
    String? coverColor,
    String? visibility,
  }) {
    return repository.createBoard(
      name: name,
      userUid: userUid,
      workspaceId: workspaceId,
      isPersonal: isPersonal,
      backgroundUrl: backgroundUrl,
      coverColor: coverColor,
      visibility: visibility,
    );
  }

}
