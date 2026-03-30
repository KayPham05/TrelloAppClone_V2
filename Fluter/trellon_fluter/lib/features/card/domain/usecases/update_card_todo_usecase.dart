import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UpdateCardTodoUseCase {
  final ICardRepository repository;

  UpdateCardTodoUseCase(this.repository);

  Future<CardEntity> call({required String cardId, required String todoId, required bool isCompleted}) async {
    return await repository.updateTodoItem(cardId: cardId, todoId: todoId, isCompleted: isCompleted);
  }
}
