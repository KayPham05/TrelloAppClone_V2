import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/i_card_repository.dart';
import 'card_detail_state.dart';
import '../../domain/usecases/add_card_comment_usecase.dart';
import '../../domain/usecases/upload_attachment_usecase.dart';
import '../../domain/usecases/get_attachments_usecase.dart';
import '../../domain/usecases/delete_attachment_usecase.dart';
import '../../domain/usecases/delete_attachment_usecase.dart';
import '../../domain/usecases/update_attachment_description_usecase.dart';
import '../../domain/usecases/upload_card_cover_usecase.dart';
import '../../../../core/data_sources/user_local_data_source.dart';

class CardDetailCubit extends Cubit<CardDetailState> {
  final ICardRepository repository;
  final AddCardCommentUseCase addCardCommentUseCase;
  final UploadAttachmentUseCase uploadAttachmentUseCase;
  final GetAttachmentsUseCase getAttachmentsUseCase;
  final DeleteAttachmentUseCase deleteAttachmentUseCase;
  final UpdateAttachmentDescriptionUseCase updateAttachmentDescriptionUseCase;
  final UploadCardCoverUseCase uploadCardCoverUseCase;

  CardDetailCubit(
    this.repository,
    this.addCardCommentUseCase,
    this.uploadAttachmentUseCase,
    this.getAttachmentsUseCase,
    this.deleteAttachmentUseCase,
    this.updateAttachmentDescriptionUseCase,
    this.uploadCardCoverUseCase,
  ) : super(CardDetailLoading());

  Future<void> loadCardDetails(CardEntity card) async {
    emit(CardDetailLoading());
    try {
      // Refresh the card from the server to get the latest backgroundUrl etc.
      final latestCard = await repository.getCard(card.id);
      
      final futures = await Future.wait([
        repository.getTodoItems(cardId: card.id),
        repository.getCardMembers(cardId: card.id),
        repository.getComments(cardId: card.id),
        repository.getAttachments(cardId: card.id),
      ]);

      emit(CardDetailLoaded(
        card: latestCard.copyWith(fileUrls: futures[3] as List<FileUrlEntity>),
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

  Future<void> updateBackgroundUrl(String newBackgroundUrl) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        await repository.updateCard(
          cardId: currentState.card.id, 
          title: currentState.card.title,
          backgroundUrl: newBackgroundUrl,
        );
        emit(currentState.copyWith(card: currentState.card.copyWith(backgroundUrl: newBackgroundUrl)));
      } catch (e) {
        // Handle error silently or surface
      }
    }
  }

  Future<void> uploadCover(String filePath) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final backgroundUrl = await uploadCardCoverUseCase.call(
          cardId: currentState.card.id,
          filePath: filePath,
        );
        await updateBackgroundUrl(backgroundUrl);
      } catch (e) {
        // surface error or ignore
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

  Future<void> loadPotentialMembers(String boardId) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final potential = await repository.getBoardMembers(boardId: boardId);
        emit(currentState.copyWith(potentialMembers: potential));
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> addMember(String userUId, String boardId) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final requesterUId = await UserLocalDataSource().getUserId();
        if (requesterUId == null) return;

        await repository.addCardMember(
          cardId: currentState.card.id,
          userUId: userUId,
          requesterUId: requesterUId,
          boardId: boardId,
        );
        // Refresh members
        final members = await repository.getCardMembers(cardId: currentState.card.id);
        emit(currentState.copyWith(members: members));
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> removeMember(String userUId, String boardId) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final requesterUId = await UserLocalDataSource().getUserId();
        if (requesterUId == null) return;

        await repository.removeCardMember(
          cardId: currentState.card.id,
          userUId: userUId,
          requesterUId: requesterUId,
          boardId: boardId,
        );
        // Refresh members
        final members = await repository.getCardMembers(cardId: currentState.card.id);
        emit(currentState.copyWith(members: members));
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> toggleLabel(String title, String colorCode) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      final currentLabels = List<CardLabelEntity>.from(currentState.card.labels);
      final existingIndex = currentLabels.indexWhere((l) => l.title == title && l.colorCode.toUpperCase() == colorCode.toUpperCase());

      if (existingIndex != -1) {
        // Label exists, delete it
        final labelToRemove = currentLabels[existingIndex];
        currentLabels.removeAt(existingIndex);
        
        // Update local state first (Optimistic)
        emit(currentState.copyWith(card: currentState.card.copyWith(labels: currentLabels)));
        
        try {
          await repository.deleteCardLabel(cardId: currentState.card.id, labelId: labelToRemove.id);
        } catch (e) {
          // Revert or surface error
        }
      } else {
        // Optimistic UI fallback: We can do a loading state or just wait. It's fast enough to await usually.
        // Or generate a fake ID. Better to just await since ID is needed for future deletions.
        try {
          final newLabel = await repository.addCardLabel(
            cardId: currentState.card.id,
            title: title,
            colorCode: colorCode,
          );
          currentLabels.add(newLabel);
          emit(currentState.copyWith(card: currentState.card.copyWith(labels: currentLabels)));
        } catch (e) {
          // Revert or handle error
        }
      }
    }
  }

  Future<void> updateDueDate(DateTime dueDate) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        await repository.updateDueDate(cardId: currentState.card.id, dueDate: dueDate);
        emit(currentState.copyWith(card: currentState.card.copyWith(dueDate: dueDate)));
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
