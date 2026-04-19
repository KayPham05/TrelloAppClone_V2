import '../repositories/i_card_repository.dart';

class UpdateAttachmentDescriptionUseCase {
  final ICardRepository repository;

  UpdateAttachmentDescriptionUseCase(this.repository);

  Future<void> call({required String cardId, required String fileId, String? description}) async {
    return await repository.updateAttachmentDescription(cardId: cardId, fileId: fileId, description: description);
  }
}
