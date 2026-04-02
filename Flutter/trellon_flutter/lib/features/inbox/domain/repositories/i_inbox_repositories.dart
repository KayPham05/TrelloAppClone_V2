import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

abstract class InboxRepositories {
  Future<List<CardEntity>> getInboxCard({required String userUId});
  Future<CardEntity> addInboxCard({required String userUId, required String cardTitle});
}