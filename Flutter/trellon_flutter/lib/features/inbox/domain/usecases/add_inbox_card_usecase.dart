import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import '../repositories/i_inbox_repositories.dart';

class AddInboxCardUseCase {
  final InboxRepositories repo;

  AddInboxCardUseCase(this.repo);

  Future<CardEntity> call({required String userUId, required String cardTitle, DateTime? dueDate}) async {
    return await repo.addInboxCard(userUId: userUId, cardTitle: cardTitle, dueDate: dueDate);
  }
}
