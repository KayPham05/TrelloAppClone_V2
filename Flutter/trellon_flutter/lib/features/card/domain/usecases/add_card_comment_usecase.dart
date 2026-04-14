import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/card/domain/repositories/i_card_repository.dart';

class AddCardCommentUseCase {
  final ICardRepository repo;

  AddCardCommentUseCase(this.repo);

  Future<CommentEntity> call({required String cardId, required String content, required String userUId}) async {
    return await repo.addComment(cardId: cardId, content: content, userUId: userUId);
  }
}
