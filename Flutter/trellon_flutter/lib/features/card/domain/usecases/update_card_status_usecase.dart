import '../entities/card_entity.dart';
import '../repositories/i_card_repository.dart';

class UpdateCardStatusUseCase {
  final ICardRepository repository;

  UpdateCardStatusUseCase(this.repository);

  Future<CardEntity> call({required String cardId, required String newStatus, required String userUId}) async {
    return await repository.updateStatus(cardId: cardId, newStatus: newStatus, userUId: userUId);
  }
}
