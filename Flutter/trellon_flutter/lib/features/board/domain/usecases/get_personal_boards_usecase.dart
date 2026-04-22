import '../repositories/board_repository.dart';
import '../entities/board_entity.dart';

class GetPersonalBoardsUseCase {
  final BoardRepository repository;

  GetPersonalBoardsUseCase(this.repository);

  Future<List<BoardEntity>> call(String userUid) {
    return repository.getPersonalBoards(userUid);
  }
}
