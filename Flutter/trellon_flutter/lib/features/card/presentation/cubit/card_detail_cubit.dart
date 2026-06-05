import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/i_card_repository.dart';
import 'card_detail_state.dart';
import '../../domain/usecases/add_card_comment_usecase.dart';
import '../../domain/usecases/upload_attachment_usecase.dart';
import '../../domain/usecases/get_attachments_usecase.dart';
import '../../domain/usecases/delete_attachment_usecase.dart';
import '../../domain/usecases/update_attachment_description_usecase.dart';
import '../../domain/usecases/upload_card_cover_usecase.dart';
import '../../../../core/data_sources/user_local_data_source.dart';

import 'package:apptreolon/features/inbox/domain/repositories/i_inbox_repositories.dart';

class CardDetailCubit extends Cubit<CardDetailState> {
  final ICardRepository repository;
  final InboxRepositories inboxRepository;
  final AddCardCommentUseCase addCardCommentUseCase;
  final UploadAttachmentUseCase uploadAttachmentUseCase;
  final GetAttachmentsUseCase getAttachmentsUseCase;
  final DeleteAttachmentUseCase deleteAttachmentUseCase;
  final UpdateAttachmentDescriptionUseCase updateAttachmentDescriptionUseCase;
  final UploadCardCoverUseCase uploadCardCoverUseCase;

  bool _isInboxCard = false;

  CardDetailCubit(
    this.repository,
    this.inboxRepository,
    this.addCardCommentUseCase,
    this.uploadAttachmentUseCase,
    this.getAttachmentsUseCase,
    this.deleteAttachmentUseCase,
    this.updateAttachmentDescriptionUseCase,
    this.uploadCardCoverUseCase,
  ) : super(CardDetailLoading());

  Future<void> loadCardDetails(CardEntity card, {bool isInboxCard = false, String? boardId}) async {
    _isInboxCard = isInboxCard;
    emit(CardDetailLoading());
    try {
      CardEntity latestCard = card;
      if (!isInboxCard) {
        // Refresh the card from the server to get the latest backgroundUrl etc.
        final fetched = await repository.getCard(card.id);
        // API does not return boardName/listName/boardBackgroundUrl — preserve them from original card
        latestCard = fetched.copyWith(
          boardName: fetched.boardName ?? card.boardName,
          listName: fetched.listName ?? card.listName,
          boardBackgroundUrl: fetched.boardBackgroundUrl ?? card.boardBackgroundUrl,
          boardId: fetched.boardId ?? card.boardId,
        );
      }
      
      final futures = await Future.wait([
        isInboxCard ? inboxRepository.getTodoItems(cardId: card.id) : repository.getTodoItems(cardId: card.id),
        if (!isInboxCard) repository.getCardMembers(cardId: card.id) else Future.value(<CardMemberEntity>[]),
        isInboxCard ? inboxRepository.getComments(cardId: card.id) : repository.getComments(cardId: card.id),
        isInboxCard ? inboxRepository.getAttachments(cardId: card.id) : repository.getAttachments(cardId: card.id),
        if (boardId != null) repository.getBoardMembers(boardId: boardId) else Future.value(<CardMemberEntity>[]),
      ]);

      emit(CardDetailLoaded(
        card: latestCard.copyWith(fileUrls: futures[3] as List<FileUrlEntity>),
        todos: futures[0] as List<TodoItemEntity>,
        members: futures[1] as List<CardMemberEntity>,
        comments: futures[2] as List<CommentEntity>,
        potentialMembers: futures.length > 4 ? futures[4] as List<CardMemberEntity> : const [],
      ));
    } catch (e) {
      emit(CardDetailError(e.toString()));
    }
  }

  Future<void> toggleTodoItem(String todoId, bool isCompleted) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        if (_isInboxCard) {
          await inboxRepository.updateTodoItem(cardId: currentState.card.id, todoId: todoId, isCompleted: isCompleted);
        } else {
          await repository.updateTodoItem(cardId: currentState.card.id, todoId: todoId, isCompleted: isCompleted);
        }
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

        late CommentEntity newComment;
        if (_isInboxCard) {
          newComment = await inboxRepository.addComment(
            cardId: currentState.card.id,
            content: content,
            userUId: userUId,
          );
        } else {
          newComment = await addCardCommentUseCase.call(
            cardId: currentState.card.id,
            content: content,
            userUId: userUId,
          );
        }

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
        if (_isInboxCard) {
          await inboxRepository.addTodoItem(
            cardId: currentState.card.id, 
            todoTitle: content,
          );
          final updatedTodos = await inboxRepository.getTodoItems(cardId: currentState.card.id);
          emit(currentState.copyWith(todos: updatedTodos));
        } else {
          await repository.addTodoItem(
            cardId: currentState.card.id, 
            todoTitle: content,
          );
          final updatedTodos = await repository.getTodoItems(cardId: currentState.card.id);
          emit(currentState.copyWith(todos: updatedTodos));
        }
      } catch (e) {
        // Handle error silently or surface
      }
    }
  }

  Future<void> updateDescription(String newDescription) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        if (_isInboxCard) {
          await inboxRepository.updateInboxCard(
            cardId: currentState.card.id,
            userUId: userUId,
            description: newDescription,
            title: currentState.card.title,
            backgroundUrl: currentState.card.backgroundUrl,
            dueDate: currentState.card.dueDate,
            status: currentState.card.status,
          );
        } else {
          await repository.updateCard(
            cardId: currentState.card.id,
            title: currentState.card.title,
            userUId: userUId,
            description: newDescription,
            dueDate: currentState.card.dueDate,
            backgroundUrl: currentState.card.backgroundUrl,
            position: currentState.card.position,
            listId: currentState.card.listId,
          );
        }
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
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        if (_isInboxCard) {
          await inboxRepository.updateInboxCard(
            cardId: currentState.card.id,
            userUId: userUId,
            backgroundUrl: newBackgroundUrl,
            title: currentState.card.title,
            description: currentState.card.description,
            dueDate: currentState.card.dueDate,
            status: currentState.card.status,
          );
        } else {
          await repository.updateCard(
            cardId: currentState.card.id,
            title: currentState.card.title,
            userUId: userUId,
            backgroundUrl: newBackgroundUrl,
            description: currentState.card.description,
            dueDate: currentState.card.dueDate,
            position: currentState.card.position,
            listId: currentState.card.listId,
          );
        }
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
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        final backgroundUrl = await uploadCardCoverUseCase.call(
          cardId: currentState.card.id,
          filePath: filePath,
          userUId: userUId,
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
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        if (_isInboxCard) {
          await inboxRepository.updateInboxCard(
            cardId: currentState.card.id, 
            userUId: userUId,
            status: newStatus,
            title: currentState.card.title,
            description: currentState.card.description,
            dueDate: currentState.card.dueDate,
            backgroundUrl: currentState.card.backgroundUrl,
          );
          emit(currentState.copyWith(card: currentState.card.copyWith(status: newStatus)));
        } else {
          await repository.updateStatus(cardId: currentState.card.id, newStatus: newStatus, userUId: userUId);
          emit(currentState.copyWith(card: currentState.card.copyWith(status: newStatus)));
        }
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
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        late FileUrlEntity fileUrl;
        if (_isInboxCard) {
          fileUrl = await inboxRepository.uploadAttachment(
            cardId: currentState.card.id,
            filePath: filePath,
            userUId: userUId,
            description: description,
          );
        } else {
          fileUrl = await uploadAttachmentUseCase.call(
            cardId: currentState.card.id,
            filePath: filePath,
            userUId: userUId,
            description: description,
          );
        }
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
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        if (_isInboxCard) {
          await inboxRepository.deleteAttachment(cardId: currentState.card.id, fileId: fileId, userUId: userUId);
        } else {
          await deleteAttachmentUseCase.call(cardId: currentState.card.id, fileId: fileId, userUId: userUId);
        }
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
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        if (_isInboxCard) {
          await inboxRepository.updateAttachmentDescription(
            cardId: currentState.card.id,
            fileId: fileId,
            userUId: userUId,
            description: newDescription,
          );
        } else {
          await updateAttachmentDescriptionUseCase.call(
            cardId: currentState.card.id,
            fileId: fileId,
            userUId: userUId,
            description: newDescription,
          );
        }
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

  Future<void> updateMemberRole({
    required String userUId,
    required String newRole,
    required String boardId,
  }) async {
    final currentState = state;
    if (currentState is CardDetailLoaded) {
      try {
        final requesterUId = await UserLocalDataSource().getUserId();
        if (requesterUId == null) return;

        await repository.updateCardMemberRole(
          cardId: currentState.card.id,
          userUId: userUId,
          role: newRole,
          requesterUId: requesterUId,
          boardId: boardId,
        );
        // Refresh members
        final members = await repository.getCardMembers(cardId: currentState.card.id);
        emit(currentState.copyWith(members: members));
      } catch (e) {
        // Handle error
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
        final userUId = await UserLocalDataSource().getUserId() ?? '';
        if (_isInboxCard) {
          await inboxRepository.updateInboxCard(
            cardId: currentState.card.id,
            userUId: userUId,
            dueDate: dueDate,
            title: currentState.card.title,
            description: currentState.card.description,
            backgroundUrl: currentState.card.backgroundUrl,
            status: currentState.card.status,
          );
        } else {
          await repository.updateDueDate(cardId: currentState.card.id, dueDate: dueDate, userUId: userUId);
        }
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

  // ─── Move Card ────────────────────────────────────────────────────────────

  /// Di chuyển card từ bất kỳ đâu vào inbox tại vị trí [position].
  Future<void> moveToInbox(int position) async {
    final currentState = state;
    if (currentState is! CardDetailLoaded) return;
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      await inboxRepository.moveCardToInbox(
        cardId: currentState.card.id,
        userUId: userUId,
        position: position,
      );
      emit(CardDetailMoved());
    } catch (e) {
      emit(CardDetailError('Không thể di chuyển card: ${e.toString()}'));
      emit(currentState);
    }
  }

  /// Di chuyển card đến một list trong board, tại vị trí [position].
  Future<void> moveToBoard(String newListId, int position) async {
    final currentState = state;
    if (currentState is! CardDetailLoaded) return;
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      await repository.updateListUId(
        cardId: currentState.card.id,
        newListId: newListId,
        userUId: userUId,
      );
      emit(CardDetailMoved());
    } catch (e) {
      emit(CardDetailError('Không thể di chuyển card: ${e.toString()}'));
      emit(currentState);
    }
  }

  /// Lấy danh sách lists cho một board (UI phải truyền BoardRepository trực tiếp thay vì dùng cubit này).
  Future<List<dynamic>> getListsForBoard(String boardId) async {
    return [];
  }

  // ─── Archive / Delete ─────────────────────────────────────────────────────

  Future<void> archiveCard() async {
    final currentState = state;
    if (currentState is! CardDetailLoaded) return;
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      await repository.archiveCard(cardId: currentState.card.id, userUId: userUId);
      emit(CardDetailArchived());
    } catch (e) {
      emit(CardDetailError('Không thể lưu trữ thẻ: ${e.toString()}'));
      emit(currentState);
    }
  }

  Future<void> unarchiveCard() async {
    final currentState = state;
    if (currentState is! CardDetailLoaded) return;
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      await repository.unarchiveCard(cardId: currentState.card.id, userUId: userUId);
      // Stay on the same state, just UI will be updated via boolean callback in UI layer
    } catch (e) {
      emit(CardDetailError('Không thể khôi phục thẻ: ${e.toString()}'));
      emit(currentState);
    }
  }

  Future<void> deleteCard() async {
    final currentState = state;
    if (currentState is! CardDetailLoaded) return;
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      await repository.deleteCard(cardId: currentState.card.id, userUId: userUId);
      emit(CardDetailDeleted());
    } catch (e) {
      emit(CardDetailError('Không thể xóa thẻ: ${e.toString()}'));
      emit(currentState);
    }
  }

  Future<void> joinCard(String boardId) async {
    final currentState = state;
    if (currentState is! CardDetailLoaded) return;
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      await repository.joinCard(
        cardId: currentState.card.id,
        userUId: userUId,
        boardId: boardId,
      );
      // Refresh members
      final members = await repository.getCardMembers(cardId: currentState.card.id);
      emit(currentState.copyWith(members: members));
    } catch (_) {}
  }
}
