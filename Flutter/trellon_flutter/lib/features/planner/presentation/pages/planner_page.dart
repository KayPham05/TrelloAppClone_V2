import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../init_dependencies.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import '../widgets/planner_day_row_widget.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  String _getMonthName(int month) {
    const names = ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6','Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12'];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PlannerCubit>()..loadMonth(_currentMonth),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF), // Miro Canvas White
        body: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getMonthName(_currentMonth.month),
                        style: const TextStyle(
                          color: Color(0xFF050505), // Miro Ink Deep
                          fontSize: 28,
                          fontWeight: FontWeight.w600, // Slightly bolder for Miro headings
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF050505), size: 22),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF050505)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // ── Days List ────────────────────────────────────────────────
              Expanded(
                child: BlocBuilder<PlannerCubit, PlannerState>(
                  builder: (context, state) {
                    if (state is PlannerLoading) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD02F))); // Miro Yellow
                    } else if (state is PlannerError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                    } else if (state is PlannerLoaded) {
                      final _days = state.days;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _days.length,
                        itemBuilder: (ctx, i) {
                          final day = _days[i];
                          final now = DateTime.now();
                          final bool isToday = day.date.year == now.year &&
                              day.date.month == now.month &&
                              day.date.day == now.day;
                          final bool isLast = day.date == _days.last.date;

                          return PlannerDayRowWidget(
                            day: day,
                            isToday: isToday,
                            isLast: isLast,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

