import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class GetAttachmentsUseCase {
  final ICardRepository repository;

  GetAttachmentsUseCase(this.repository);

  Future<List<FileUrlEntity>> call({required String cardId}) async {
    return await repository.getAttachments(cardId: cardId);
  }
}
