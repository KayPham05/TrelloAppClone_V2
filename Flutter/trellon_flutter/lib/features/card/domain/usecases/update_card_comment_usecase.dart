import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UpdateCardCommentUseCase {
  final ICardRepository repository;

  UpdateCardCommentUseCase(this.repository);

  Future<CommentEntity> call({
    required String commentId,
    required String content,
    required String userUId,
  }) {
    return repository.updateComment(
      commentId: commentId,
      content: content,
      userUId: userUId,
    );
  }
}
