import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/inbox/domain/repositories/i_inbox_repositories.dart';
import '../datasources/inbox_remote_data_source.dart';

class InboxRepositoriesImpl extends InboxRepositories {
  final InboxRemoteDataSource remoteDataSource;

  InboxRepositoriesImpl({required this.remoteDataSource});

  @override
  Future<List<CardEntity>> getInboxCard({required String userUId}) async {
    return await remoteDataSource.getInboxCards(userUId);
  }

  @override
  Future<CardEntity> addInboxCard({
    required String userUId,
    required String cardTitle,
  }) async {
    return await remoteDataSource.addInboxCard(userUId, cardTitle);
  }

  @override
  Future<CardEntity> updateInboxCard({
    required String cardId,
    required String userUId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? backgroundUrl,
    String? status,
  }) async {
    return await remoteDataSource.updateInboxCard(
      cardId,
      userUId,
      title: title,
      description: description,
      dueDate: dueDate,
      backgroundUrl: backgroundUrl,
      status: status,
    );
  }

  @override
  Future<void> deleteInboxCard({required String cardId, required String userUId}) async {
    await remoteDataSource.deleteInboxCard(cardId, userUId);
  }

  @override
  Future<List<TodoItemEntity>> getTodoItems({required String cardId}) async {
    return await remoteDataSource.getTodoItems(cardId);
  }

  @override
  Future<CardEntity> addTodoItem({required String cardId, required String todoTitle}) async {
    return await remoteDataSource.addTodoItem(cardId, todoTitle);
  }

  @override
  Future<CardEntity> updateTodoItem({required String cardId, required String todoId, required bool isCompleted}) async {
    return await remoteDataSource.updateTodoItem(cardId, todoId, isCompleted);
  }

  @override
  Future<List<CommentEntity>> getComments({required String cardId}) async {
    return await remoteDataSource.getComments(cardId);
  }

  @override
  Future<CommentEntity> addComment({required String cardId, required String userUId, required String content}) async {
    return await remoteDataSource.addComment(cardId, userUId, content);
  }

  @override
  Future<List<FileUrlEntity>> getAttachments({required String cardId}) async {
    return await remoteDataSource.getAttachments(cardId);
  }

  @override
  Future<FileUrlEntity> uploadAttachment({required String cardId, required String filePath, required String userUId, String? description}) async {
    return await remoteDataSource.uploadAttachment(cardId, filePath, userUId, description);
  }

  @override
  Future<void> deleteAttachment({required String cardId, required String fileId, required String userUId}) async {
    await remoteDataSource.deleteAttachment(cardId, fileId, userUId);
  }

  @override
  Future<void> updateAttachmentDescription({required String cardId, required String fileId, required String userUId, String? description}) async {
    await remoteDataSource.updateAttachmentDescription(cardId, fileId, userUId, description);
  }
}
