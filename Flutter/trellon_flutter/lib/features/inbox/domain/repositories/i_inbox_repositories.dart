import 'package:apptreolon/features/card/domain/entities/card_entity.dart';

abstract class InboxRepositories {
  Future<List<CardEntity>> getInboxCard({required String userUId});
  Future<CardEntity> addInboxCard({required String userUId, required String cardTitle, DateTime? dueDate});
  Future<CardEntity> updateInboxCard({required String cardId, required String userUId, String? title, String? description, DateTime? dueDate, String? backgroundUrl, String? status});
  Future<void> deleteInboxCard({required String cardId, required String userUId});
  
  // New consolidated inbox APIs
  Future<List<TodoItemEntity>> getTodoItems({required String cardId});
  Future<CardEntity> addTodoItem({required String cardId, required String todoTitle});
  Future<CardEntity> updateTodoItem({required String cardId, required String todoId, required bool isCompleted});
  Future<List<CommentEntity>> getComments({required String cardId});
  Future<CommentEntity> addComment({required String cardId, required String userUId, required String content});
  Future<List<FileUrlEntity>> getAttachments({required String cardId});
  Future<FileUrlEntity> uploadAttachment({required String cardId, required String filePath, required String userUId, String? description});
  Future<void> deleteAttachment({required String cardId, required String fileId, required String userUId});
  Future<void> updateAttachmentDescription({required String cardId, required String fileId, required String userUId, String? description});
  Future<void> renameAttachment({required String cardId, required String fileId, required String userUId, required String fileName});

  // Move-card support
  Future<void> moveCardToInbox({required String cardId, required String userUId, required int position});
  Future<void> reorderInboxCards({required String userUId, required List<Map<String, dynamic>> items});
}
