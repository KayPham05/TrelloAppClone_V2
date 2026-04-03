import '../repositories/i_card_repository.dart';

class GetCardDescriptionUseCase {
  final ICardRepository repository;

  GetCardDescriptionUseCase(this.repository);

  Future<String> call({required String cardId}) async {
    return await repository.getCardDescription(cardId: cardId);
  }
}
