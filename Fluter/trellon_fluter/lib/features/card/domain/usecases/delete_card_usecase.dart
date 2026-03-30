import '../repositories/i_card_repository.dart';

class DeleteCardUseCase {
  final ICardRepository repository;

  DeleteCardUseCase(this.repository);

  Future<void> call({required String cardId}) async {
    return await repository.deleteCard(cardId: cardId);
  }
}
