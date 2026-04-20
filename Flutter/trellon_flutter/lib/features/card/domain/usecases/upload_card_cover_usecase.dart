import '../repositories/i_card_repository.dart';

class UploadCardCoverUseCase {
  final ICardRepository repository;

  UploadCardCoverUseCase(this.repository);

  Future<String> call({required String cardId, required String filePath}) async {
    return await repository.uploadCardCover(cardId: cardId, filePath: filePath);
  }
}
