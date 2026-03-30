import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/planner_entity.dart';
import '../widgets/planner_day_row_widget.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late List<PlannerDayEntity> _days;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _days = _generateDays();
  }

  List<PlannerDayEntity> _generateDays() {
    final now = _today;
    final lastDay = DateTime(now.year, now.month + 1, 0); // last day of month
    final List<PlannerDayEntity> days = [];

    // Mock tasks cho một số ngày
    final Map<int, List<String>> mockTasks = {
      now.day: ['Implement Board Screen', 'Code Review'],
      now.day + 2: ['Meeting nhóm', 'Demo sản phẩm'],
      now.day + 5: ['Deadline nộp bài'],
    };

    for (int d = now.day; d <= lastDay.day; d++) {
      final date = DateTime(now.year, now.month, d);
      days.add(PlannerDayEntity(
        date: date,
        taskTitles: mockTasks[d] ?? [],
      ));
    }
    // Add a couple days from next month
    for (int d = 1; d <= 3; d++) {
      final date = DateTime(now.year, now.month + 1, d);
      days.add(PlannerDayEntity(date: date, taskTitles: []));
    }
    return days;
  }

  String _getMonthName(int month) {
    const names = ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6','Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12'];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(_today.month);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      monthName,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 22),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // ── Days List ────────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _days.length,
                itemBuilder: (ctx, i) {
                  final day = _days[i];
                  final bool isToday = day.date.year == _today.year &&
                      day.date.month == _today.month &&
                      day.date.day == _today.day;
                  final bool isLast = day.date == _days.last.date;

                  return PlannerDayRowWidget(
                    day: day,
                    isToday: isToday,
                    isLast: isLast,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
