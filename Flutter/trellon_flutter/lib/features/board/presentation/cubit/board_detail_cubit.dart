import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'board_detail_state.dart';
import '../../domain/entities/list_entity.dart';
import '../../../card/domain/entities/card_entity.dart';
import '../../../card/domain/usecases/update_list_uid_usecase.dart';

class BoardDetailCubit extends Cubit<BoardDetailState> {
  final UpdateListUIdUseCase updateListUIdUseCase;

  // History copy state mapping rollback when calling API error
  List<ListEntity>? _previousLists;

  BoardDetailCubit({
    required this.updateListUIdUseCase,
  }) : super(BoardDetailInitial());

  /// Load Fake Data (Domain Entity format) vì Backend chưa có API getAllList()
  Future<void> loadBoard(String boardId, String boardName) async {
    emit(BoardDetailLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // fake delay
      
      // Mock data wrapped in domain entities
      final mockLists = [
        ListEntity(
          id: 'list_1',
          name: 'Cần làm',
          position: 0,
          boardId: boardId,
          cards: [
            CardEntity(id: 'card_1_1', title: 'Tài liệu thiết kế hệ thống giao diện', position: 0, listId: 'list_1', description: 'Có label'),
            CardEntity(id: 'card_1_2', title: 'Xem lại mockup trang landing hi-fi', position: 1, listId: 'list_1', dueDate: DateTime.now()),
            CardEntity(id: 'card_1_3', title: 'Lập kế hoạch ngân sách Q4', position: 2, listId: 'list_1'),
            CardEntity(id: 'card_1_4', title: 'Xem lại chiến lược mạng xã hội', position: 3, listId: 'list_1'),
          ],
        ),
        ListEntity(
          id: 'list_2',
          name: 'Đang làm',
          position: 1,
          boardId: boardId,
          cards: [
            CardEntity(id: 'card_2_1', title: 'Tích hợp API cổng thanh toán', position: 0, listId: 'list_2', dueDate: DateTime.now().add(const Duration(days: 2))),
            CardEntity(id: 'card_2_2', title: 'Thiết kế onboarding người dùng', position: 1, listId: 'list_2'),
            CardEntity(id: 'card_2_3', title: 'Viết unit test cho auth module', position: 2, listId: 'list_2'),
            CardEntity(id: 'card_2_4', title: 'Cập nhật chính sách bảo mật', position: 3, listId: 'list_2'),
          ],
        ),
        ListEntity(
          id: 'list_3',
          name: 'Hoàn thành',
          position: 2,
          boardId: boardId,
          cards: [
            CardEntity(id: 'card_3_1', title: 'Thiết lập CI/CD pipeline', position: 0, listId: 'list_3'),
            CardEntity(id: 'card_3_2', title: 'Tái cấu trúc lớp service backend', position: 1, listId: 'list_3'),
            CardEntity(id: 'card_3_3', title: 'Phỏng vấn người dùng về UX', position: 2, listId: 'list_3'),
          ],
        ),
      ];

      emit(BoardDetailLoaded(
        boardId: boardId,
        boardName: boardName,
        lists: mockLists,
      ));
    } catch (e) {
      emit(BoardDetailError(e.toString()));
    }
  }

  void startDragging() {
    if (state is BoardDetailLoaded) {
      final currentState = state as BoardDetailLoaded;
      emit(currentState.copyWith(isDragging: true));
    }
  }

  void endDragging() {
    if (state is BoardDetailLoaded) {
      final currentState = state as BoardDetailLoaded;
      emit(currentState.copyWith(isDragging: false));
    }
  }

  void clearTransientError() {
    if (state is BoardDetailLoaded) {
      final currentState = state as BoardDetailLoaded;
      emit(currentState.copyWith(clearTransientError: true));
    }
  }

  void moveCard({
    required CardEntity card,
    required String sourceListId,
    required String targetListId,
    required int insertIndex,
  }) {
    if (state is! BoardDetailLoaded) return;
    final currentState = state as BoardDetailLoaded;

    // Lưu previous state cho rollback
    _previousLists = List.from(currentState.lists);

    try {
      final newLists = List<ListEntity>.from(currentState.lists);

      final sourceListIdx = newLists.indexWhere((l) => l.id == sourceListId);
      final targetListIdx = newLists.indexWhere((l) => l.id == targetListId);

      if (sourceListIdx == -1 || targetListIdx == -1) return;

      final sourceList = newLists[sourceListIdx];
      final sourceCards = List<CardEntity>.from(sourceList.cards);
      sourceCards.removeWhere((c) => c.id == card.id);
      
      // Update source
      newLists[sourceListIdx] = sourceList.copyWith(cards: sourceCards);

      final targetList = newLists[targetListIdx];
      final targetCards = List<CardEntity>.from(targetList.cards);

      // Thêm bài vào insertIndex
      final updatedCard = card.copyWith(listId: targetListId);
      // Validate index
      final safeIndex = (insertIndex >= 0 && insertIndex <= targetCards.length) 
        ? insertIndex 
        : targetCards.length;
        
      targetCards.insert(safeIndex, updatedCard);
      
      // Cập nhật các vị trí sau khi insert
      for (var i = 0; i < targetCards.length; i++) {
        targetCards[i] = targetCards[i].copyWith(position: i);
      }

      // Update target
      newLists[targetListIdx] = targetList.copyWith(cards: targetCards);

      // Phát state mới (Optimistic update)
      emit(currentState.copyWith(lists: newLists));

      // TODO: Gắn API call thực tế với updateListUIdUseCase và xử lí Fallback.
      // Vì Backend không có List endpoints hiện tại, chúng ta giữ mock.

    } catch (e) {
      // Rollback
      if (_previousLists != null) {
        emit(currentState.copyWith(
          lists: _previousLists,
          transientError: 'Lỗi di chuyển thẻ. Đã hoàn tác.',
        ));
      }
    } finally {
      _previousLists = null;
    }
  }
}
