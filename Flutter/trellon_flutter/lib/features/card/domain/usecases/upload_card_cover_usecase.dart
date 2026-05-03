import '../repositories/i_card_repository.dart';

class UploadCardCoverUseCase {
  final ICardRepository repository;

  UploadCardCoverUseCase(this.repository);

  Future<String> call({required String cardId, required String filePath, required String userUId}) async {
    return await repository.uploadCardCover(cardId: cardId, filePath: filePath, userUId: userUId);
  }
}
