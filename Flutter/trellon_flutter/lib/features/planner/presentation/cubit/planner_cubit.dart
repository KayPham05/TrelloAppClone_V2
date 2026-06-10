import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_planner_cards_usecase.dart';
import '../../domain/entities/planner_entity.dart';
import 'planner_state.dart';
import 'package:intl/intl.dart';

import '../../../card/domain/usecases/update_card_due_date_usecase.dart';
import '../../../../core/data_sources/user_local_data_source.dart';

class PlannerCubit extends Cubit<PlannerState> {
  final GetPlannerCardsUseCase getPlannerCardsUseCase;
  final UpdateCardDueDateUseCase updateCardDueDateUseCase;
  final UserLocalDataSource userLocalDataSource;

  PlannerCubit({
    required this.getPlannerCardsUseCase,
    required this.updateCardDueDateUseCase,
    required this.userLocalDataSource,
  }) : super(PlannerInitial());

  Future<void> loadMonth(DateTime currentMonth) async {
    emit(PlannerLoading());
    try {
      final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
      final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

      // Fetch cards for the current month and the first 3 days of next month
      final fetchLastDay = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
        3,
      );
      final cardsMap = await getPlannerCardsUseCase(firstDay, fetchLastDay);

      // Generate all days for the current month
      final List<PlannerDayEntity> days = [];
      for (int d = 1; d <= lastDay.day; d++) {
        final date = DateTime(currentMonth.year, currentMonth.month, d);
        final dateString = DateFormat('yyyy-MM-dd').format(date);

        days.add(
          PlannerDayEntity(date: date, cards: cardsMap[dateString] ?? []),
        );
      }

      // Add a few days from next month for visual continuity if needed (optional)
      for (int d = 1; d <= 3; d++) {
        final date = DateTime(currentMonth.year, currentMonth.month + 1, d);
        final dateString = DateFormat('yyyy-MM-dd').format(date);

        days.add(
          PlannerDayEntity(date: date, cards: cardsMap[dateString] ?? []),
        );
      }

      emit(PlannerLoaded(days: days));
    } catch (e) {
      emit(PlannerError(message: e.toString()));
    }
  }

  void applyRealtimeCardDueDateUpdated() {
    final currentState = state;
    if (currentState is PlannerLoaded) {
      if (currentState.days.isNotEmpty) {
        loadMonth(currentState.days[0].date);
      }
    }
  }

  Future<void> updateCardDate(
    String cardId,
    DateTime newDate,
    DateTime currentMonth,
  ) async {
    try {
      final userUId = await userLocalDataSource.getUserId();
      if (userUId == null) throw Exception("User not found");

      await updateCardDueDateUseCase(
        cardId: cardId,
        dueDate: newDate,
        userUId: userUId,
      );

      // Reload the month to refresh the UI
      await loadMonth(currentMonth);
    } catch (e) {
      // In a real app, you might want to show an error or rollback
      debugPrint('Failed to update card date: $e');
    }
  }
}
