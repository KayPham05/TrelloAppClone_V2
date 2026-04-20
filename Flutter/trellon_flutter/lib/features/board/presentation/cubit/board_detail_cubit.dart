import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../card/data/models/card_model.dart';
import '../../data/datasources/board_detail_remote_data_source.dart';
import '../../data/models/list_model.dart';
import '../../../card/domain/entities/card_entity.dart';
import 'board_detail_state.dart';

class BoardDetailCubit extends Cubit<BoardDetailState> {
  final BoardDetailRemoteDataSource dataSource;
  final UserLocalDataSource userLocalDataSource;

  BoardDetailCubit({
    required this.dataSource,
    required this.userLocalDataSource,
  }) : super(BoardDetailInitial());

  Future<void> loadBoard({
    required String boardId,
    required String boardName,
    String? backgroundUrl,
  }) async {
    emit(BoardDetailLoading());
    try {
      // Load lists + all cards in parallel
      final results = await Future.wait([
        dataSource.getLists(boardId),
        dataSource.getCardsByBoard(boardId),
      ]);

      final listModels = results[0] as List<ListModel>;
      final cardModels = results[1] as List<CardModel>;
      final cards = cardModels.map((c) => c.toEntity()).toList();

      // Group cards by list
      final Map<String, List<CardEntity>> cardsByList = {};
      for (final card in cards) {
        final key = card.listId ?? '';
        cardsByList.putIfAbsent(key, () => []).add(card);
      }

      final lists = listModels.map((l) {
        final listCards = (cardsByList[l.id] ?? [])
          ..sort((a, b) => a.position.compareTo(b.position));
        return l.toListEntityData().copyWith(cards: listCards);
      }).toList()
        ..sort((a, b) => a.position.compareTo(b.position));

      emit(BoardDetailLoaded(
        boardId: boardId,
        boardName: boardName,
        backgroundUrl: backgroundUrl,
        lists: lists,
      ));
    } catch (e) {
      emit(BoardDetailError(e.toString()));
    }
  }

  Future<void> createList(String name) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      final position = current.lists.isEmpty ? 0 : current.lists.last.position + 1;
      final newList = await dataSource.createList(
        boardId: current.boardId,
        name: name,
        userUId: userUId,
        position: position,
      );
      final updated = [...current.lists, newList.toListEntityData()];
      emit(current.copyWith(lists: updated));
    } catch (e) {
      // Silently fail or show snackbar from UI
    }
  }

  Future<void> createCard({required String listId, required String title}) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final listIndex = current.lists.indexWhere((l) => l.id == listId);
      if (listIndex < 0) return;
      final position = current.lists[listIndex].cards.length;
      final cardModel = await dataSource.createCard(
        listId: listId,
        title: title,
        position: position,
      );
      // Refresh the board to get accurate card IDs
      await loadBoard(
        boardId: current.boardId,
        boardName: current.boardName,
        backgroundUrl: current.backgroundUrl,
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> moveCard({
    required String cardId,
    required String fromListId,
    required String toListId,
    required int newPosition,
  }) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;

    // Optimistic update
    final newLists = current.lists.map((list) {
      if (list.id == fromListId) {
        return list.copyWith(
          cards: list.cards.where((c) => c.id != cardId).toList(),
        );
      }
      if (list.id == toListId) {
        // Find the card from fromList (it may not be there anymore after optimistic update)
        final card = current.lists
            .expand((l) => l.cards)
            .where((c) => c.id == cardId)
            .firstOrNull;
        if (card == null) return list;
        final updatedCards = [...list.cards, card];
        updatedCards.sort((a, b) => a.position.compareTo(b.position));
        return list.copyWith(cards: updatedCards);
      }
      return list;
    }).toList();

    emit(current.copyWith(lists: newLists));

    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      await dataSource.moveCard(
        cardId: cardId,
        newListId: toListId,
        userUId: userUId,
      );
    } catch (e) {
      // Revert on error
      emit(current);
    }
  }

  Future<void> deleteList(String listId) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      await dataSource.deleteList(listId: listId, userUId: userUId);
      final updated = current.lists.where((l) => l.id != listId).toList();
      emit(current.copyWith(lists: updated));
    } catch (e) {
      // Silently fail
    }
  }

  void onCardMoveLocal({
    required String cardId,
    required String fromListId,
    required String toListId,
  }) {
    final current = state;
    if (current is! BoardDetailLoaded) return;

    CardEntity? movedCard;
    final newLists = current.lists.map((list) {
      if (list.id == fromListId) {
        final remaining = list.cards.where((c) {
          if (c.id == cardId) {
            movedCard = c;
            return false;
          }
          return true;
        }).toList();
        return list.copyWith(cards: remaining);
      }
      return list;
    }).toList();

    if (movedCard == null) return;

    final finalLists = newLists.map((list) {
      if (list.id == toListId) {
        return list.copyWith(cards: [...list.cards, movedCard!]);
      }
      return list;
    }).toList();

    emit(current.copyWith(lists: finalLists));
  }

  Future<void> updateBackground(String backgroundUrl) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      await dataSource.updateBoardBackground(
        boardId: current.boardId,
        boardName: current.boardName,
        backgroundUrl: backgroundUrl,
      );
      emit(current.copyWith(backgroundUrl: backgroundUrl));
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> uploadBackground(String filePath) async {
    final current = state;
    if (current is! BoardDetailLoaded) return;
    try {
      final newUrl = await dataSource.uploadBoardBackground(
        boardId: current.boardId,
        filePath: filePath,
      );
      emit(current.copyWith(backgroundUrl: newUrl));
    } catch (e) {
      // Silently fail
    }
  }
}
