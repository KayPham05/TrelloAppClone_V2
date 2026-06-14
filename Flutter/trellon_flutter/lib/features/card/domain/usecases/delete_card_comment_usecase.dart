import '../repositories/i_card_repository.dart';

class DeleteCardCommentUseCase {
  final ICardRepository repository;

  DeleteCardCommentUseCase(this.repository);

  Future<void> call({
    required String commentId,
    required String userUId,
  }) {
    return repository.deleteComment(commentId: commentId, userUId: userUId);
  }
}
