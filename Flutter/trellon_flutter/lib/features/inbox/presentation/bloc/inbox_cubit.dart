import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../card/domain/usecases/delete_card_usecase.dart';

import '../../domain/usecases/add_inbox_card_usecase.dart';
import '../../domain/usecases/get_user_inbox_card.dart';
import '../../domain/repositories/i_inbox_repositories.dart';
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

  Future<void> fetchInboxCards() async {
    emit(InboxLoading());

    try {
      final userUId = await userLocalDataSource.getUserId();
      if (userUId == null) {
        emit(const InboxError(message: "Không tìm thấy user ID. Vui lòng đăng nhập lại."));
        return;
      }

      final result = await getInboxCardsUseCase.call(userUId: userUId);

      if (result.isEmpty) {
        emit(InboxEmpty());
      } else {
        emit(InboxLoaded(cards: result));
      }
    } catch (e) {
      emit(InboxError(message: "Lỗi hệ thống: ${e.toString()}"));
    }
  }

  Future<void> addCardToInbox(String title) async {
    final currentState = state;
    if (currentState is! InboxLoaded) {
      emit(InboxLoading());
    }

    try {
      final userUId = await userLocalDataSource.getUserId();
      if (userUId == null) {
        emit(const InboxError(message: "Không tìm thấy user ID. Vui lòng đăng nhập lại."));
        return;
      }

      await addInboxCardUseCase.call(userUId: userUId, cardTitle: title);
      // Khi thêm thành công, gọi lại API để load lại danh sách mới nhất
      await fetchInboxCards();
    } catch (e) {
      // Nếu lỗi, hiện lỗi tóm tắt và khôi phục state nếu trước đó là Loaded
      emit(InboxError(message: "Không thể thêm Card: ${e.toString()}"));
      if (currentState is InboxLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      final userUId = await userLocalDataSource.getUserId() ?? '';
      await deleteCardUseCase.call(cardId: cardId, userUId: userUId);
      await fetchInboxCards();
    } catch (e) {
      emit(InboxError(message: "Không thể xóa: ${e.toString()}"));
      await fetchInboxCards();
    }
  }

  Future<void> toggleCardStatus(String cardId, bool isCompleted) async {
    final currentState = state;
    if (currentState is! InboxLoaded) return;
    try {
      final card = currentState.cards.firstWhere((c) => c.id == cardId);
      final userUId = await userLocalDataSource.getUserId() ?? '';
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
      await fetchInboxCards();
    } catch (e) {
      emit(InboxError(message: "Không thể cập nhật trạng thái: ${e.toString()}"));
      await fetchInboxCards();
    }
  }
}
