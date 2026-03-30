import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class AddCardUseCase {
  final ICardRepository repository;

  AddCardUseCase(this.repository);

  Future<CardEntity> call({required String listId, required String title, required int position}) async {
    return await repository.addCard(listId: listId, title: title, position: position);
  }
}
