import '../../domain/repositories/i_card_repository.dart';

class UpdateAttachmentNameUseCase {
  final ICardRepository repository;

  UpdateAttachmentNameUseCase(this.repository);

  Future<void> call({
    required String cardId,
    required String fileId,
    required String userUId,
    required String fileName,
  }) {
    return repository.renameAttachment(
      cardId: cardId,
      fileId: fileId,
      userUId: userUId,
      fileName: fileName,
    );
  }
}
