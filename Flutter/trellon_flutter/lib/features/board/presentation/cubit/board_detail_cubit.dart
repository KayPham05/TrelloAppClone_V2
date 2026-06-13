import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/card_status_values.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../card/data/models/card_model.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../../../card/domain/usecases/update_card_status_usecase.dart';
import '../../../card/domain/usecases/update_list_uid_usecase.dart';
import '../../domain/usecases/save_recent_board_usecase.dart';
import '../../data/datasources/board_remote_data_source.dart';
import '../../data/models/list_model.dart';
import '../../domain/entities/list_entity.dart';
import 'board_detail_state.dart';

class BoardDetailCubit extends Cubit<BoardDetailState> {
  final BoardRemoteDataSource dataSource;
  final UserLocalDataSource userLocalDataSource;
  final UpdateListUIdUseCase updateListUIdUseCase;
  final UpdateCardStatusUseCase updateCardStatusUseCase;
  final SaveRecentBoardUseCase saveRecentBoardUseCase;

  // Rollback snapshot for optimistic updates
  List<ListEntity>? _previousLists;

  BoardDetailCubit({
    required this.dataSource,
    required this.userLocalDataSource,
    required this.updateListUIdUseCase,
    required this.updateCardStatusUseCase,
    required this.saveRecentBoardUseCase,
  }) : super(BoardDetailInitial());

  // ─── Load Board (Real API) ─────────────────────────────────────────────────

  /// Loads lists and cards from backend in parallel, then groups cards into lists.
  Future<void> loadBoard(
    String boardId,
    String boardName, {
    String? backgroundUrl,
    String? workspaceId,
    String? workspaceName,
    String? visibility,
    bool isPersonal = false,
  }) async {
    emit(BoardDetailLoading());
    try {
      // Fetch lists, cards, and board role in parallel
      final userUId = await userLocalDataSource.getUserId() ?? '';

      // Save recent board in background
      saveRecentBoardUseCase(userUId, boardId).catchError((_) {});

      final results = await Future.wait([
        dataSource.getLists(boardId),
        dataSource.getCardsByBoard(boardId),
        dataSource.getUserRoleInBoard(boardId: boardId, userUId: userUId),
      ]);

      final listModels = results[0] as List<ListModel>;
      final cardModels = results[1] as List<CardModel>;
      final boardRole = results[2] as String?;

      // Convert cards to entities
      final cards = cardModels.map((c) => c.toEntity()).toList();

      // Group cards by their listId
      final Map<String, List<CardEntity>> cardsByList = {};
      for (final card in cards) {
        final key = card.listId ?? '';
        cardsByList.putIfAbsent(key, () => []).add(card);
      }

      // Build ListEntity list — each list gets its own cards, sorted by position
      final lists = listModels.map((l) {
        final listCards = List<CardEntity>.from(cardsByList[l.id] ?? [])
          ..sort((a, b) => a.position.compareTo(b.position));
        return ListEntity(
          id: l.id,
          name: l.name,
          position: l.position,
          status: l.status,
          boardId: l.boardId,
          cards: listCards,
        );
      }).toList()..sort((a, b) => a.position.compareTo(b.position));

      emit(
        BoardDetailLoaded(
          boardId: boardId,
          boardName: boardName,
          backgroundUrl: backgroundUrl,
          lists: lists,
          boardRole: boardRole,
          boardVisibility: visibility,
          workspaceId: workspaceId,
          workspaceName: workspaceName,
          isPersonal: isPersonal,
        ),
      );
    } catch (e) {
      emit(BoardDetailError(e.toString()));
    }
  }

  Future<void> reload() async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    await loadBoard(
      current.boardId,
      current.boardName,
      backgroundUrl: current.backgroundUrl,
      workspaceId: current.workspaceId,
      workspaceName: current.workspaceName,
      visibility: current.boardVisibility,
    );
  }

  // ─── Create List ───────────────────────────────────────────────────────────

  Future<void> createList(String name) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      final position = current.lists.isEmpty
          ? 0
          : current.lists.last.position + 1;
      final newListModel = await dataSource.createList(
        boardId: current.boardId,
        name: name,
        userUId: userUId,
        position: position,
      );
      final newList = ListEntity(
        id: newListModel.id,
        name: newListModel.name,
        position: newListModel.position,
        status: newListModel.status,
        boardId: newListModel.boardId,
        cards: const [],
      );
      emit(current.copyWith(lists: [...current.lists, newList]));
    } catch (_) {
      // Silently fail — user stays in current state
    }
  }

  // ─── Create Card ───────────────────────────────────────────────────────────

  Future<void> createCard({
    required String listId,
    required String title,
  }) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final listIndex = current.lists.indexWhere((l) => l.id == listId);
      if (listIndex < 0) return;
      final position = current.lists[listIndex].cards.length;
      final userUId = await userLocalDataSource.getUserId() ?? '';
      await dataSource.createCard(
        listId: listId,
        title: title,
        position: position,
        userUId: userUId,
      );
      // Reload to get the real card ID from backend
      await loadBoard(
        current.boardId,
        current.boardName,
        backgroundUrl: current.backgroundUrl,
      );
    } catch (_) {
      // Silently fail
    }
  }

  // ─── Update Card Status ────────────────────────────────────────────────────

  Future<void> toggleCardStatus(
    String listId,
    String cardId,
    bool isCompleted,
  ) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      final card = current.lists
          .expand((l) => l.cards)
          .firstWhere((c) => c.id == cardId);
      final newStatus = isCompleted
          ? CardStatusValues.completed
          : CardStatusValues.calculate(CardStatusValues.toDo, card.dueDate);

      // Optimistic upate
      final newLists = List<ListEntity>.from(current.lists);
      final listIdx = newLists.indexWhere((l) => l.id == listId);
      if (listIdx != -1) {
        final cards = List<CardEntity>.from(newLists[listIdx].cards);
        final cardIdx = cards.indexWhere((c) => c.id == cardId);
        if (cardIdx != -1) {
          cards[cardIdx] = cards[cardIdx].copyWith(status: newStatus);
          newLists[listIdx] = newLists[listIdx].copyWith(cards: cards);
          emit(current.copyWith(lists: newLists));
        }
      }

      await updateCardStatusUseCase(
        cardId: cardId,
        newStatus: newStatus,
        userUId: userUId,
      );
    } catch (_) {
      // Revert if error
      if (state is BoardDetailLoaded) {
        final lastState = state as BoardDetailLoaded;
        emit(
          lastState.copyWith(
            transientError: 'Không thể cập nhật trạng thái thẻ.',
          ),
        );
      }
    }
  }

  // ─── Delete List ──────────────────────────────────────────────────────────

  Future<void> deleteList(String listId) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      await dataSource.deleteList(listId: listId, userUId: userUId);
      final updated = current.lists.where((l) => l.id != listId).toList();
      emit(current.copyWith(lists: updated));
    } catch (_) {
      // Silently fail
    }
  }

  // ─── Move Card (Optimistic + API) ─────────────────────────────────────────

  void moveCard({
    required CardEntity card,
    required String sourceListId,
    required String targetListId,
    required int insertIndex,
  }) {
    if (state is! BoardDetailLoaded) return;
    final currentState = state as BoardDetailLoaded;

    _previousLists = List.from(currentState.lists);

    try {
      final newLists = List<ListEntity>.from(currentState.lists);

      final sourceListIdx = newLists.indexWhere((l) => l.id == sourceListId);
      final targetListIdx = newLists.indexWhere((l) => l.id == targetListId);
      if (sourceListIdx == -1 || targetListIdx == -1) return;

      // Remove from source
      final sourceList = newLists[sourceListIdx];
      final sourceCards = List<CardEntity>.from(sourceList.cards)
        ..removeWhere((c) => c.id == card.id);
      newLists[sourceListIdx] = sourceList.copyWith(cards: sourceCards);

      // Insert into target
      final targetList = newLists[targetListIdx];
      final targetCards = List<CardEntity>.from(targetList.cards);
      final updatedCard = card.copyWith(listId: targetListId);
      final safeIndex = (insertIndex >= 0 && insertIndex <= targetCards.length)
          ? insertIndex
          : targetCards.length;
      targetCards.insert(safeIndex, updatedCard);

      // Re-number positions
      for (var i = 0; i < targetCards.length; i++) {
        targetCards[i] = targetCards[i].copyWith(position: i);
      }
      newLists[targetListIdx] = targetList.copyWith(cards: targetCards);

      // Optimistic update — immediate UI feedback
      emit(currentState.copyWith(lists: newLists));

      // API call — async, rollback on error
      _persistMoveCard(card.id, targetListId, currentState);
    } catch (e) {
      if (_previousLists != null) {
        emit(
          currentState.copyWith(
            lists: _previousLists,
            transientError: 'Lỗi di chuyển thẻ. Đã hoàn tác.',
          ),
        );
      }
    } finally {
      _previousLists = null;
    }
  }

  Future<void> _persistMoveCard(
    String cardId,
    String newListId,
    BoardDetailLoaded snapshotOnError,
  ) async {
    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      await dataSource.moveCard(
        cardId: cardId,
        newListId: newListId,
        userUId: userUId,
      );
    } catch (_) {
      // Rollback to snapshot
      if (state is BoardDetailLoaded) {
        emit(
          snapshotOnError.copyWith(
            transientError: 'Lỗi di chuyển thẻ. Đã hoàn tác.',
          ),
        );
      }
    }
  }

  // ─── Move List (Optimistic + API reorder) ─────────────────────────────────

  void moveList({required ListEntity list, required int insertIndex}) {
    if (state is! BoardDetailLoaded) return;
    final currentState = state as BoardDetailLoaded;

    _previousLists = List.from(currentState.lists);

    try {
      final newLists = List<ListEntity>.from(currentState.lists)
        ..removeWhere((l) => l.id == list.id);

      final safeIndex = (insertIndex >= 0 && insertIndex <= newLists.length)
          ? insertIndex
          : newLists.length;
      newLists.insert(safeIndex, list);

      // Re-number positions
      for (var i = 0; i < newLists.length; i++) {
        newLists[i] = newLists[i].copyWith(position: i);
      }

      // Optimistic update
      emit(currentState.copyWith(lists: newLists));

      // API call async
      _persistReorderLists(currentState.boardId, newLists, currentState);
    } catch (e) {
      if (_previousLists != null) {
        emit(
          currentState.copyWith(
            lists: _previousLists,
            transientError: 'Lỗi di chuyển cột. Đã hoàn tác.',
          ),
        );
      }
    } finally {
      _previousLists = null;
    }
  }

  Future<void> _persistReorderLists(
    String boardId,
    List<ListEntity> updatedLists,
    BoardDetailLoaded snapshotOnError,
  ) async {
    try {
      // Convert to ListModel for the data source
      final listModels = updatedLists
          .map(
            (l) => ListModel(
              id: l.id,
              name: l.name,
              position: l.position,
              status: l.status,
              boardId: l.boardId,
            ),
          )
          .toList();
      final userUId = await userLocalDataSource.getUserId() ?? '';
      await dataSource.reorderLists(
        boardId: boardId,
        lists: listModels,
        userUId: userUId,
      );
    } catch (_) {
      if (state is BoardDetailLoaded) {
        emit(
          snapshotOnError.copyWith(
            transientError: 'Lỗi sắp xếp cột. Đã hoàn tác.',
          ),
        );
      }
    }
  }

  // ─── Transient Error Control ───────────────────────────────────────────────

  void clearTransientError() {
    if (state is BoardDetailLoaded) {
      final currentState = state as BoardDetailLoaded;
      emit(currentState.copyWith(clearTransientError: true));
    }
  }

  // ─── Board Settings ────────────────────────────────────────────────────────

  Future<void> updateBoardName(String newName) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    final userUId = await userLocalDataSource.getUserId() ?? '';
    try {
      await dataSource.updateBoard(
        boardId: current.boardId,
        boardName: newName,
        userUId: userUId,
        backgroundUrl: current.backgroundUrl,
        visibility: current.boardVisibility,
        workspaceUId: current.workspaceId,
      );
      emit(current.copyWith(boardName: newName));
    } catch (_) {
      emit(current.copyWith(transientError: 'Không thể đổi tên bảng.'));
    }
  }

  Future<void> updateBoardBackground(String backgroundUrl) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    final userUId = await userLocalDataSource.getUserId() ?? '';
    try {
      await dataSource.updateBoard(
        boardId: current.boardId,
        boardName: current.boardName,
        userUId: userUId,
        backgroundUrl: backgroundUrl,
      );
      emit(current.copyWith(backgroundUrl: backgroundUrl));
    } catch (_) {
      emit(current.copyWith(transientError: 'Không thể đổi phông nền.'));
    }
  }

  Future<String?> uploadAndSetBackground(String filePath) async {
    final current = state;
    if (current is! BoardDetailLoaded) return null;
    final userUId = await userLocalDataSource.getUserId() ?? '';
    try {
      final url = await dataSource.uploadBoardBackground(
        boardId: current.boardId,
        filePath: filePath,
        userUId: userUId,
      );
      emit(current.copyWith(backgroundUrl: url));
      return url;
    } catch (_) {
      emit(current.copyWith(transientError: 'Không thể tải ảnh lên.'));
      return null;
    }
  }

  Future<bool> transferBoardWorkspace(
    String newWorkspaceUId,
    String newWorkspaceName,
  ) async {
    final current = state;
    if (current is! BoardDetailLoaded) return false;
    final userUId = await userLocalDataSource.getUserId() ?? '';
    try {
      final success = await dataSource.transferBoardWorkspace(
        boardId: current.boardId,
        newWorkspaceUId: newWorkspaceUId,
        requesterUId: userUId,
      );
      if (success) {
        emit(
          current.copyWith(
            workspaceId: newWorkspaceUId,
            workspaceName: newWorkspaceName,
          ),
        );
      }
      return success;
    } catch (_) {
      emit(
        current.copyWith(
          transientError: 'Không thể chuyển không gian làm việc.',
        ),
      );
      return false;
    }
  }

  Future<void> updateBoardVisibility(String visibility) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    final userUId = await userLocalDataSource.getUserId() ?? '';
    try {
      await dataSource.updateBoard(
        boardId: current.boardId,
        boardName: current.boardName,
        userUId: userUId,
        visibility: visibility,
      );
      emit(current.copyWith(boardVisibility: visibility));
    } catch (_) {
      emit(current.copyWith(transientError: 'Không thể cập nhật hiển thị.'));
    }
  }

  Future<void> deleteBoard(String boardId) async {
    final userUId = await userLocalDataSource.getUserId() ?? '';
    try {
      await dataSource.deleteBoard(boardId: boardId, userUId: userUId);
    } catch (_) {
      final current = state;
      if (current is BoardDetailLoaded) {
        emit(current.copyWith(transientError: 'Không thể xóa bảng.'));
      }
    }
  }

  // ─── Archive All Completed Cards ──────────────────────────────────────────

  Future<int> archiveAllCompletedCards() async {
    final current = state;
    if (current is! BoardDetailLoaded) return 0;
    final userUId = await userLocalDataSource.getUserId() ?? '';
    try {
      final count = await dataSource.archiveAllCompleted(
        boardId: current.boardId,
        userUId: userUId,
      );
      if (count > 0) {
        // Reload board to reflect removed completed cards
        await loadBoard(
          current.boardId,
          current.boardName,
          backgroundUrl: current.backgroundUrl,
          workspaceId: current.workspaceId,
          workspaceName: current.workspaceName,
          visibility: current.boardVisibility,
        );
      }
      return count;
    } catch (_) {
      return 0;
    }
  }
  // ─── Realtime Updates (SignalR) ──────────────────────────────────────────

  void applyRealtimeBoardUpdated(Map<String, dynamic> payload) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;
    emit(
      current.copyWith(
        boardName: payload['boardName'],
        backgroundUrl: payload['backgroundUrl'],
        boardVisibility: payload['visibility'],
      ),
    );
  }

  void applyRealtimeBoardBackgroundUpdated(String url) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;
    emit(current.copyWith(backgroundUrl: url));
  }

  void applyRealtimeListCreated(Map<String, dynamic> payload) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    // Avoid duplicates
    if (current.lists.any((l) => l.id == payload['listUId'])) return;

    final newList = ListEntity(
      id: payload['listUId'],
      name: payload['listName'],
      position: payload['position'],
      status: payload['status'] ?? 'Active',
      boardId: payload['boardUId'],
      cards: const [],
    );

    final updatedLists = [...current.lists, newList]
      ..sort((a, b) => a.position.compareTo(b.position));

    emit(current.copyWith(lists: updatedLists));
  }

  void applyRealtimeListStatusUpdated(String listUId, String status) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    if (status == 'Archived' || status == 'Deleted') {
      final updatedLists = current.lists.where((l) => l.id != listUId).toList();
      emit(current.copyWith(lists: updatedLists));
    } else {
      final updatedLists = current.lists.map((l) {
        return l.id == listUId ? l.copyWith(status: status) : l;
      }).toList();
      emit(current.copyWith(lists: updatedLists));
    }
  }

  void applyRealtimeListReordered(List<dynamic> order) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    final Map<String, int> positions = {};
    for (var i = 0; i < order.length; i++) {
      positions[order[i].toString()] = i;
    }

    final updatedLists = current.lists.map((l) {
      final pos = positions[l.id];
      return pos != null ? l.copyWith(position: pos) : l;
    }).toList()..sort((a, b) => a.position.compareTo(b.position));

    emit(current.copyWith(lists: updatedLists));
  }

  void applyRealtimeCardAdded(Map<String, dynamic> payload) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    final listId = payload['listUId'];
    if (listId == null) return;

    // Check if card exists in any list
    for (final list in current.lists) {
      if (list.cards.any((c) => c.id == payload['cardUId'])) return;
    }

    final newCard = CardModel.fromJson(payload).toEntity();

    final updatedLists = current.lists.map((l) {
      if (l.id == listId) {
        final updatedCards = [...l.cards, newCard]
          ..sort((a, b) => a.position.compareTo(b.position));
        return l.copyWith(cards: updatedCards);
      }
      return l;
    }).toList();

    emit(current.copyWith(lists: updatedLists));
  }

  void applyRealtimeCardUpdated(Map<String, dynamic> payload) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;
    final cardId = payload['cardUId'];

    final updatedLists = current.lists.map((l) {
      final cardIdx = l.cards.indexWhere((c) => c.id == cardId);
      if (cardIdx != -1) {
        final updatedCards = List<CardEntity>.from(l.cards);
        updatedCards[cardIdx] = CardModel.fromJson(payload).toEntity();
        return l.copyWith(cards: updatedCards);
      }
      return l;
    }).toList();

    emit(current.copyWith(lists: updatedLists));
  }

  void applyRealtimeCardDeleted(String cardUId) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    final updatedLists = current.lists.map((l) {
      final updatedCards = l.cards.where((c) => c.id != cardUId).toList();
      return l.copyWith(cards: updatedCards);
    }).toList();

    emit(current.copyWith(lists: updatedLists));
  }

  void applyRealtimeCardMoved(String cardUId, String newListUId, int position) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    CardEntity? movedCard;
    final intermediateLists = current.lists.map((l) {
      final cardIdx = l.cards.indexWhere((c) => c.id == cardUId);
      if (cardIdx != -1) {
        movedCard = l.cards[cardIdx];
        final updatedCards = List<CardEntity>.from(l.cards)..removeAt(cardIdx);
        return l.copyWith(cards: updatedCards);
      }
      return l;
    }).toList();

    if (movedCard == null) return;

    final finalLists = intermediateLists.map((l) {
      if (l.id == newListUId) {
        final updatedCards = List<CardEntity>.from(l.cards);
        final safePos = position.clamp(0, updatedCards.length);
        updatedCards.insert(
          safePos,
          movedCard!.copyWith(listId: newListUId, position: position),
        );

        // Re-sort just in case
        for (int i = 0; i < updatedCards.length; i++) {
          updatedCards[i] = updatedCards[i].copyWith(position: i);
        }
        return l.copyWith(cards: updatedCards);
      }
      return l;
    }).toList();

    emit(current.copyWith(lists: finalLists));
  }

  void applyRealtimeCommentAdded(Map<String, dynamic> payload) {
    // Typically comments are handled in a different Cubit or detail page.
    // If BoardDetail contains comment counts, update them here.
  }

  void applyRealtimeCommentDeleted(String commentUId, String cardUId) {
    // Same as above.
  }
}
