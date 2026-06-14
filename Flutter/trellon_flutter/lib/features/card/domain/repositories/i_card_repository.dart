import '../../domain/entities/card_entity.dart';

abstract class ICardRepository {
  Future<CardEntity> getCard(String cardId);
  Future<CardEntity> addCard({required String listId, required String title, required int position, required String userUId});
  Future<CardEntity> updateCard({required String cardId, required String title, required String userUId, String? description, DateTime? dueDate, String? backgroundUrl, int? position, String? listId});
  Future<void> deleteCard({required String cardId, required String userUId});
  Future<String> getCardDescription({required String cardId});
  Future<CardEntity> updateListUId({required String cardId, required String newListId, required String userUId});
  Future<CardEntity> updateStatus({required String cardId, required String newStatus, required String userUId});

  Future<CardEntity> addTodoItem({required String cardId, required String todoTitle});
  Future<CardEntity> updateTodoItem({required String cardId, required String todoId, required bool isCompleted});
  Future<CardEntity> updateDueDate({required String cardId, required DateTime dueDate, required String userUId});

  Future<List<CommentEntity>> getComments({required String cardId});
  Future<CommentEntity> addComment({required String cardId, required String content, required String userUId});
  Future<CommentEntity> updateComment({required String commentId, required String content, required String userUId});
  Future<void> deleteComment({required String commentId, required String userUId});
  Future<FileUrlEntity> uploadCommentAttachment({required String commentId, required String filePath, required String userUId});
  Future<void> deleteCommentAttachment({required String commentId, required String fileId, required String userUId});
  Future<List<CardMemberEntity>> getCardMembers({required String cardId});
  Future<List<TodoItemEntity>> getTodoItems({required String cardId});
  
  Future<List<FileUrlEntity>> getAttachments({required String cardId});
  Future<FileUrlEntity> uploadAttachment({required String cardId, required String filePath, required String userUId, String? description});
  Future<String> uploadCardCover({required String cardId, required String filePath, required String userUId});
  Future<void> deleteAttachment({required String cardId, required String fileId, required String userUId});
  Future<void> updateAttachmentDescription({required String cardId, required String fileId, required String userUId, String? description});
  Future<void> renameAttachment({required String cardId, required String fileId, required String userUId, required String fileName});

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
  Future<void> updateCardMemberRole({
    required String cardId,
    required String userUId,
    required String role,
    required String requesterUId,
    required String boardId,
  });

  // Archive
  Future<void> archiveCard({required String cardId, required String userUId});
  Future<void> unarchiveCard({required String cardId, required String userUId});

  // Join card
  Future<void> joinCard({required String cardId, required String userUId, required String boardId});
}
