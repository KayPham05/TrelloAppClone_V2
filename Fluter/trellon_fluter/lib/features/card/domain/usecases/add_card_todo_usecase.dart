import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class AddCardTodoUseCase {
  final ICardRepository repository;

  AddCardTodoUseCase(this.repository);

  Future<CardEntity> call({required String cardId, required String todoTitle}) async {
    return await repository.addTodoItem(cardId: cardId, todoTitle: todoTitle);
  }
}
