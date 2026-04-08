import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/i_card_repository.dart';
import 'card_detail_state.dart';

class CardDetailCubit extends Cubit<CardDetailState> {
  final ICardRepository repository;

  CardDetailCubit(this.repository) : super(CardDetailLoading());

  Future<void> loadCardDetails(CardEntity card) async {
    emit(CardDetailLoading());
    try {
      final futures = await Future.wait([
        repository.getTodoItems(cardId: card.id),
        repository.getCardMembers(cardId: card.id),
        repository.getComments(cardId: card.id),
      ]);

      emit(CardDetailLoaded(
        card: card,
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
}
