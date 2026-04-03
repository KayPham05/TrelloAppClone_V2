import 'package:apptreolon/features/inbox/domain/repositories/i_inbox_repositories.dart';
import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

class GetInboxCardUseCase {
  InboxRepositories repo;
  GetInboxCardUseCase(this.repo);

  Future<List<CardEntity>> call({required String userUId}) async {
    return await repo.getInboxCard(userUId: userUId);
  }
}