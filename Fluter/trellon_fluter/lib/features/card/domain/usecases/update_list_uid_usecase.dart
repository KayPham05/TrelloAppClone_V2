import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UpdateListUIdUseCase {
  final ICardRepository repository;

  UpdateListUIdUseCase(this.repository);

  Future<CardEntity> call({required String cardId, required String newListId, required int newPosition}) async {
    return await repository.updateListUId(cardId: cardId, newListId: newListId, newPosition: newPosition);
  }
}
