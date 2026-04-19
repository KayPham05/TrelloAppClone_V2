import '../repositories/i_card_repository.dart';

class DeleteAttachmentUseCase {
  final ICardRepository repository;

  DeleteAttachmentUseCase(this.repository);

  Future<void> call({required String cardId, required String fileId}) async {
    return await repository.deleteAttachment(cardId: cardId, fileId: fileId);
  }
}
