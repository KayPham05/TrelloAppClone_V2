import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_planner_cards_usecase.dart';
import '../../domain/entities/planner_entity.dart';
import 'planner_state.dart';
import 'package:intl/intl.dart';

class PlannerCubit extends Cubit<PlannerState> {
  final GetPlannerCardsUseCase getPlannerCardsUseCase;

  PlannerCubit({required this.getPlannerCardsUseCase}) : super(PlannerInitial());

  Future<void> loadMonth(DateTime currentMonth) async {
    emit(PlannerLoading());
    try {
      final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
      final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

      // Fetch cards for the current month
      final cardsMap = await getPlannerCardsUseCase(firstDay, lastDay);

      // Generate all days for the current month
      final List<PlannerDayEntity> days = [];
      for (int d = 1; d <= lastDay.day; d++) {
        final date = DateTime(currentMonth.year, currentMonth.month, d);
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        days.add(PlannerDayEntity(
          date: date,
          cards: cardsMap[dateString] ?? [],
        ));
      }

      // Add a few days from next month for visual continuity if needed (optional)
      for (int d = 1; d <= 3; d++) {
        final date = DateTime(currentMonth.year, currentMonth.month + 1, d);
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        days.add(PlannerDayEntity(
          date: date,
          cards: cardsMap[dateString] ?? [],
        ));
      }

      emit(PlannerLoaded(days: days));
    } catch (e) {
      emit(PlannerError(message: e.toString()));
    }
  }
}
