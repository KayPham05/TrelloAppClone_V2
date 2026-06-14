import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UploadCommentAttachmentUseCase {
  final ICardRepository repository;

  UploadCommentAttachmentUseCase(this.repository);

  Future<FileUrlEntity> call({
    required String commentId,
    required String filePath,
    required String userUId,
  }) {
    return repository.uploadCommentAttachment(
      commentId: commentId,
      filePath: filePath,
      userUId: userUId,
    );
  }
}
