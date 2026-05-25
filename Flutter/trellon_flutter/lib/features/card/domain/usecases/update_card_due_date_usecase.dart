import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UpdateCardDueDateUseCase {
  final ICardRepository repository;

  UpdateCardDueDateUseCase(this.repository);

  Future<CardEntity> call({required String cardId, required DateTime dueDate, required String userUId}) async {
    return await repository.updateDueDate(cardId: cardId, dueDate: dueDate, userUId: userUId);
  }
}
