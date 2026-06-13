import '../entities/board_entity.dart';
import '../repositories/board_repository.dart';

class GetStarredBoardsUseCase {
  final BoardRepository repository;

  GetStarredBoardsUseCase(this.repository);

  Future<List<BoardEntity>> call(String userUid) async {
    return repository.getStarredBoards(userUid);
  }
}
