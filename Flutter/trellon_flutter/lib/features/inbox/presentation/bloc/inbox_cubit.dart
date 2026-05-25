import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../core/errors/app_exception_mapper.dart';
import '../../../card/domain/usecases/delete_card_usecase.dart';
import '../../domain/repositories/i_inbox_repositories.dart';
import '../../domain/usecases/add_inbox_card_usecase.dart';
import '../../domain/usecases/get_user_inbox_card.dart';
import 'inbox_state.dart';

class InboxCubit extends Cubit<InboxState> {
  final GetInboxCardUseCase getInboxCardsUseCase;
  final AddInboxCardUseCase addInboxCardUseCase;
  final DeleteCardUseCase deleteCardUseCase;
  final InboxRepositories inboxRepositories;
  final UserLocalDataSource userLocalDataSource;

  InboxCubit({
    required this.getInboxCardsUseCase,
    required this.addInboxCardUseCase,
    required this.deleteCardUseCase,
    required this.inboxRepositories,
    required this.userLocalDataSource,
  }) : super(InboxInitial());

  Future<void> fetchInboxCards({bool showLoading = true}) async {
    if (showLoading) emit(InboxLoading());

    try {
      final userUId = await userLocalDataSource.getUserId();

      if (userUId == null || userUId.isEmpty) {
        emit(const InboxError(
          message: 'Không tìm thấy user ID. Vui lòng đăng nhập lại.',
        ));
        return;
      }

      final result = await getInboxCardsUseCase.call(userUId: userUId);

      if (result.isEmpty) {
        emit(InboxEmpty());
      } else {
        emit(InboxLoaded(cards: result));
      }
    } catch (e) {
      emit(InboxError(message: AppExceptionMapper.map(e)));
    }
  }

  Future<void> addCardToInbox(String title) async {
    final currentState = state;

    if (currentState is! InboxLoaded) {
      emit(InboxLoading());
    }

    try {
      final userUId = await userLocalDataSource.getUserId();

      if (userUId == null || userUId.isEmpty) {
        emit(const InboxError(
          message: 'Không tìm thấy user ID. Vui lòng đăng nhập lại.',
        ));
        return;
      }

      await addInboxCardUseCase.call(
        userUId: userUId,
        cardTitle: title,
      );

      await fetchInboxCards(showLoading: false);
    } catch (e) {
      emit(InboxError(
        message: 'Không thể thêm Card: ${AppExceptionMapper.map(e)}',
      ));
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      final userUId = await userLocalDataSource.getUserId();

      if (userUId == null || userUId.isEmpty) {
        emit(const InboxError(
          message: 'Không tìm thấy user ID. Vui lòng đăng nhập lại.',
        ));
        return;
      }

      await deleteCardUseCase.call(
        cardId: cardId,
        userUId: userUId,
      );

      await fetchInboxCards(showLoading: false);
    } catch (e) {
      emit(InboxError(
        message: 'Không thể xóa Card: ${AppExceptionMapper.map(e)}',
      ));
    }
  }

  Future<void> toggleCardStatus(String cardId, bool isCompleted) async {
    final currentState = state;

    if (currentState is! InboxLoaded) return;

    try {
      final userUId = await userLocalDataSource.getUserId();

      if (userUId == null || userUId.isEmpty) {
        emit(const InboxError(
          message: 'Không tìm thấy user ID. Vui lòng đăng nhập lại.',
        ));
        return;
      }

      final card = currentState.cards.firstWhere((c) => c.id == cardId);
      final newStatus = isCompleted ? 'Completed' : 'To Do';

      await inboxRepositories.updateInboxCard(
        cardId: cardId,
        userUId: userUId,
        status: newStatus,
        title: card.title,
        description: card.description,
        dueDate: card.dueDate,
        backgroundUrl: card.backgroundUrl,
      );

      await fetchInboxCards(showLoading: false);
    } catch (e) {
      emit(InboxError(
        message: 'Không thể cập nhật trạng thái: ${AppExceptionMapper.map(e)}',
      ));
    }
  }

  /// Kéo-thả sắp xếp lại vị trí card trong inbox.
  /// Cập nhật local ngay lập tức, sau đó gọi API.
  /// Nếu API lỗi thì rollback về state cũ.
  Future<void> reorderCards(int oldIndex, int newIndex) async {
    final currentState = state;

    if (currentState is! InboxLoaded) return;
    if (oldIndex == newIndex) return;

    final cards = List.of(currentState.cards);

    final card = cards.removeAt(oldIndex);
    final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    cards.insert(insertIndex, card);

    emit(InboxLoaded(cards: cards));

    try {
      final userUId = await userLocalDataSource.getUserId();

      if (userUId == null || userUId.isEmpty) {
        emit(currentState);
        emit(const InboxError(
          message: 'Không tìm thấy user ID. Vui lòng đăng nhập lại.',
        ));
        return;
      }

      final items = cards.asMap().entries.map((entry) {
        return {
          'cardUId': entry.value.id,
          'position': entry.key,
        };
      }).toList();

      await inboxRepositories.reorderInboxCards(
        userUId: userUId,
        items: items,
      );
    } catch (_) {
      emit(currentState);
    }
  }

  Future<String?> getUserId() {
    return userLocalDataSource.getUserId();
  }
}