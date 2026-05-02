import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UploadAttachmentUseCase {
  final ICardRepository repository;

  UploadAttachmentUseCase(this.repository);

  Future<FileUrlEntity> call({required String cardId, required String filePath, required String userUId, String? description}) async {
    return await repository.uploadAttachment(cardId: cardId, filePath: filePath, userUId: userUId, description: description);
  }
}
