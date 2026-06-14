import '../repositories/i_card_repository.dart';

class DeleteCommentAttachmentUseCase {
  final ICardRepository repository;

  DeleteCommentAttachmentUseCase(this.repository);

  Future<void> call({
    required String commentId,
    required String fileId,
    required String userUId,
  }) {
    return repository.deleteCommentAttachment(
      commentId: commentId,
      fileId: fileId,
      userUId: userUId,
    );
  }
}
