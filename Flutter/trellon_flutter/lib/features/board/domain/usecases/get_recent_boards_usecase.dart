import '../../domain/repositories/board_repository.dart';
import '../../domain/entities/board_entity.dart';

class GetRecentBoardsUseCase {
  final BoardRepository repository;

  GetRecentBoardsUseCase(this.repository);

  Future<List<BoardEntity>> call(String userUid) async {
    return await repository.getRecentBoards(userUid);
  }
}
