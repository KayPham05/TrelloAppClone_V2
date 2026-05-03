import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UpdateCardUseCase {
  final ICardRepository repository;

  UpdateCardUseCase(this.repository);

  Future<CardEntity> call({required String cardId, required String title, required String userUId, String? description, DateTime? dueDate}) async {
    return await repository.updateCard(cardId: cardId, title: title, userUId: userUId, description: description, dueDate: dueDate);
  }
}
