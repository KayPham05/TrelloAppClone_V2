import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import 'planner_day_row_widget.dart';

class PlannerCalendarWidget extends StatelessWidget {
  final DateTime currentMonth;

  const PlannerCalendarWidget({super.key, required this.currentMonth});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        if (state is PlannerLoading || state is PlannerInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PlannerError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (state is PlannerLoaded) {
          if (state.days.isEmpty) {
            return const Center(
              child: Text('Không có công việc nào trong tháng này.'),
            );
          }
          final today = DateTime.now();
          return ListView.builder(
            itemCount: state.days.length,
            itemBuilder: (context, index) {
              final day = state.days[index];
              final isToday = day.date.year == today.year &&
                  day.date.month == today.month &&
                  day.date.day == today.day;
              return PlannerDayRowWidget(
                day: day,
                isToday: isToday,
                isLast: index == state.days.length - 1,
                plannerMonth: currentMonth,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
