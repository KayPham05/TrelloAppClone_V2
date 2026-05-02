import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_card_usecase.dart';
import '../../domain/usecases/update_card_usecase.dart';
import '../../domain/usecases/delete_card_usecase.dart';
import '../../domain/usecases/get_card_description_usecase.dart';
import '../../domain/usecases/update_list_uid_usecase.dart';
import '../../domain/usecases/update_card_status_usecase.dart';
import '../../domain/usecases/add_card_todo_usecase.dart';
import '../../domain/usecases/update_card_todo_usecase.dart';
import '../../domain/usecases/update_card_due_date_usecase.dart';
import 'card_state.dart';
import '../../../../core/data_sources/user_local_data_source.dart';

class CardCubit extends Cubit<CardState> {
  final AddCardUseCase addCardUseCase;
  final UpdateCardUseCase updateCardUseCase;
  final DeleteCardUseCase deleteCardUseCase;
  final GetCardDescriptionUseCase getCardDescriptionUseCase;
  final UpdateListUIdUseCase updateListUIdUseCase;
  final UpdateCardStatusUseCase updateCardStatusUseCase;
  final AddCardTodoUseCase addCardTodoUseCase;
  final UpdateCardTodoUseCase updateCardTodoUseCase;
  final UpdateCardDueDateUseCase updateCardDueDateUseCase;

  CardCubit({
    required this.addCardUseCase,
    required this.updateCardUseCase,
    required this.deleteCardUseCase,
    required this.getCardDescriptionUseCase,
    required this.updateListUIdUseCase,
    required this.updateCardStatusUseCase,
    required this.addCardTodoUseCase,
    required this.updateCardTodoUseCase,
    required this.updateCardDueDateUseCase,
  }) : super(CardInitial());

  Future<void> addCard({required String listId, required String title, required int position}) async {
    emit(CardLoading());
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      final card = await addCardUseCase.call(listId: listId, title: title, position: position, userUId: userUId);
      emit(CardActionSuccess(card: card));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> updateCard({required String cardId, required String title, String? description, DateTime? dueDate}) async {
    emit(CardLoading());
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      final card = await updateCardUseCase.call(cardId: cardId, title: title, userUId: userUId, description: description, dueDate: dueDate);
      emit(CardActionSuccess(card: card));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> deleteCard({required String cardId}) async {
    emit(CardLoading());
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      await deleteCardUseCase.call(cardId: cardId, userUId: userUId);
      emit(CardInitial()); // Or a specific Deleted state if needed
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> getCardDescription({required String cardId}) async {
    emit(CardLoading());
    try {
      final description = await getCardDescriptionUseCase.call(cardId: cardId);
      emit(CardDescriptionLoaded(description: description));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> updateListUId({required String cardId, required String newListId, required int newPosition}) async {
    emit(CardLoading());
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      final card = await updateListUIdUseCase.call(cardId: cardId, newListId: newListId, userUId: userUId);
      emit(CardActionSuccess(card: card));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> updateStatus({required String cardId, required String newStatus}) async {
    emit(CardLoading());
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      final card = await updateCardStatusUseCase.call(cardId: cardId, newStatus: newStatus, userUId: userUId);
      emit(CardActionSuccess(card: card));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> addTodo({required String cardId, required String todoTitle}) async {
    emit(CardLoading());
    try {
      final card = await addCardTodoUseCase.call(cardId: cardId, todoTitle: todoTitle);
      emit(CardActionSuccess(card: card));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> updateTodo({required String cardId, required String todoId, required bool isCompleted}) async {
    emit(CardLoading());
    try {
      final card = await updateCardTodoUseCase.call(cardId: cardId, todoId: todoId, isCompleted: isCompleted);
      emit(CardActionSuccess(card: card));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }

  Future<void> updateDueDate({required String cardId, required DateTime dueDate}) async {
    emit(CardLoading());
    try {
      final userUId = await UserLocalDataSource().getUserId() ?? '';
      final card = await updateCardDueDateUseCase.call(cardId: cardId, dueDate: dueDate, userUId: userUId);
      emit(CardActionSuccess(card: card));
    } catch (e) {
      emit(CardActionError(message: e.toString()));
    }
  }
}
