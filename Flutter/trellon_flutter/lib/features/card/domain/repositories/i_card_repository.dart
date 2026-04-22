import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

abstract class ICardRepository {
  Future<CardEntity> getCard(String cardId);
  Future<CardEntity> addCard({required String listId, required String title, required int position});
  Future<CardEntity> updateCard({required String cardId, required String title, String? description, DateTime? dueDate, String? backgroundUrl});
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
  
  Future<List<FileUrlEntity>> getAttachments({required String cardId});
  Future<FileUrlEntity> uploadAttachment({required String cardId, required String filePath, String? description});
  Future<String> uploadCardCover({required String cardId, required String filePath});
  Future<void> deleteAttachment({required String cardId, required String fileId});
  Future<void> updateAttachmentDescription({required String cardId, required String fileId, String? description});

  // Labels
  Future<CardLabelEntity> addCardLabel({required String cardId, required String title, required String colorCode});
  Future<void> deleteCardLabel({required String cardId, required String labelId});

  // Member Management
  Future<List<CardMemberEntity>> getBoardMembers({required String boardId});
  Future<void> addCardMember({
    required String cardId,
    required String userUId,
    required String requesterUId,
    required String boardId,
  });
  Future<void> removeCardMember({
    required String cardId,
    required String userUId,
    required String requesterUId,
    required String boardId,
  });
}
