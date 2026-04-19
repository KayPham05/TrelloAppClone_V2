import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/i_card_repository.dart';
import 'card_detail_state.dart';
import '../../domain/usecases/add_card_comment_usecase.dart';
import '../../domain/usecases/upload_attachment_usecase.dart';
import '../../domain/usecases/get_attachments_usecase.dart';
import '../../domain/usecases/delete_attachment_usecase.dart';
import '../../domain/usecases/update_attachment_description_usecase.dart';
import '../../../../core/data_sources/user_local_data_source.dart';

class CardDetailCubit extends Cubit<CardDetailState> {
  final ICardRepository repository;
  final AddCardCommentUseCase addCardCommentUseCase;
  final UploadAttachmentUseCase uploadAttachmentUseCase;
  final GetAttachmentsUseCase getAttachmentsUseCase;
  final DeleteAttachmentUseCase deleteAttachmentUseCase;
  final UpdateAttachmentDescriptionUseCase updateAttachmentDescriptionUseCase;

  CardDetailCubit(
    this.repository,
    this.addCardCommentUseCase,
    this.uploadAttachmentUseCase,
    this.getAttachmentsUseCase,
    this.deleteAttachmentUseCase,
    this.updateAttachmentDescriptionUseCase,
  ) : super(CardDetailLoading());

  Future<void> loadCardDetails(CardEntity card) async {
    emit(CardDetailLoading());
    try {
      final futures = await Future.wait([
        repository.getTodoItems(cardId: card.id),
        repository.getCardMembers(cardId: card.id),
        repository.getComments(cardId: card.id),
        repository.getAttachments(cardId: card.id),
      ]);

      emit(CardDetailLoaded(
        card: card.copyWith(fileUrls: futures[3] as List<FileUrlEntity>),
        todos: futures[0] as List<TodoItemEntity>,
        members: futures[1] as List<CardMemberEntity>,
        comments: futures[2] as List<CommentEntity>,
      ));
    } catch (e) {
      emit(CardDetailError(e.toString()));
    }
  }

  Future<void> toggleTodoItem(String todoId, bool isCompleted) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        await repository.updateTodoItem(cardId: currentState.card.id, todoId: todoId, isCompleted: isCompleted);
        final updatedTodos = currentState.todos.map((t) {
          if (t.id == todoId) return TodoItemEntity(id: t.id, title: t.title, isCompleted: isCompleted);
          return t;
        }).toList();
        emit(currentState.copyWith(todos: updatedTodos));
      } catch (e) {
        // Handle error silently or surface
      }
    }
  }

  Future<void> addComment(String content) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final userUId = await UserLocalDataSource().getUserId();
        if (userUId == null) return;

        final newComment = await addCardCommentUseCase.call(
          cardId: currentState.card.id,
          content: content,
          userUId: userUId,
        );

        final updatedComments = List<CommentEntity>.from(currentState.comments)..add(newComment);
        emit(currentState.copyWith(comments: updatedComments));
      } catch (e) {
        // Handle error silently or surface
      }
    }
  }

  Future<void> addTodoItem(String content) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        await repository.addTodoItem(
          cardId: currentState.card.id, 
          todoTitle: content,
        );
        final updatedTodos = await repository.getTodoItems(cardId: currentState.card.id);
        emit(currentState.copyWith(todos: updatedTodos));
      } catch (e) {
        // Handle error silently or surface
      }
    }
  }

  Future<void> updateDescription(String newDescription) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        await repository.updateCard(
          cardId: currentState.card.id, 
          title: currentState.card.title,
          description: newDescription,
        );
        emit(currentState.copyWith(card: currentState.card.copyWith(description: newDescription)));
      } catch (e) {
        // Handle error silently or surface
      }
    }
  }

  Future<void> updateStatus(String newStatus) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final updatedCard = await repository.updateStatus(cardId: currentState.card.id, newStatus: newStatus);
        emit(currentState.copyWith(card: updatedCard));
      } catch (e) {
        // Handle error silently or surface
      }
    }
  }

  Future<void> uploadAttachment(String filePath, {String? description}) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        emit(currentState.copyWith(isUploadingAttachment: true, clearAttachmentError: true));
        final fileUrl = await uploadAttachmentUseCase.call(
          cardId: currentState.card.id,
          filePath: filePath,
          description: description,
        );
        final updatedCard = currentState.card.copyWith(
          fileUrls: List<FileUrlEntity>.from(currentState.card.fileUrls)..add(fileUrl),
        );
        emit(currentState.copyWith(card: updatedCard, isUploadingAttachment: false, clearAttachmentError: true));
      } catch (e) {
        final isDuplicate = e.toString().contains('DUPLICATE');
        emit(currentState.copyWith(
          isUploadingAttachment: false,
          attachmentError: isDuplicate ? 'duplicate' : null,
        ));
      }
    }
  }

  Future<void> deleteAttachment(String fileId) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        await deleteAttachmentUseCase.call(cardId: currentState.card.id, fileId: fileId);
        final updatedFiles = currentState.card.fileUrls.where((f) => f.id != fileId).toList();
        emit(currentState.copyWith(card: currentState.card.copyWith(fileUrls: updatedFiles)));
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> updateAttachmentDescription(String fileId, String? newDescription) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        await updateAttachmentDescriptionUseCase.call(
          cardId: currentState.card.id,
          fileId: fileId,
          description: newDescription,
        );
        final updatedFiles = currentState.card.fileUrls.map((f) {
          if (f.id == fileId) {
            return f.copyWith(description: newDescription);
          }
          return f;
        }).toList();
        emit(currentState.copyWith(card: currentState.card.copyWith(fileUrls: updatedFiles)));
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void clearAttachmentError() {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      emit(currentState.copyWith(clearAttachmentError: true));
    }
  }
}
