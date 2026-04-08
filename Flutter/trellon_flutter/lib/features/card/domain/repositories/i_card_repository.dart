import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

abstract class ICardRepository {
  Future<CardEntity> addCard({required String listId, required String title, required int position});
  Future<CardEntity> updateCard({required String cardId, required String title, String? description, DateTime? dueDate});
  Future<void> deleteCard({required String cardId});
  Future<String> getCardDescription({required String cardId});
  Future<CardEntity> updateListUId({required String cardId, required String newListId, required int newPosition});
  Future<CardEntity> updateStatus({required String cardId, required String newStatus});

  Future<CardEntity> addTodoItem({required String cardId, required String todoTitle});
  Future<CardEntity> updateTodoItem({required String cardId, required String todoId, required bool isCompleted});
  Future<CardEntity> updateDueDate({required String cardId, required DateTime dueDate});

  Future<List<CommentEntity>> getComments({required String cardId});
  Future<CommentEntity> addComment({required String cardId, required String content, required String userUId});
  Future<List<CardMemberEntity>> getCardMembers({required String cardId});
  Future<List<TodoItemEntity>> getTodoItems({required String cardId});
}
