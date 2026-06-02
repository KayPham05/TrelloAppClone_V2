import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../init_dependencies.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import '../widgets/planner_day_row_widget.dart';
import '../widgets/add_planner_task_bottom_sheet.dart';
import '../widgets/planner_options_bottom_sheet.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late DateTime _currentMonth;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
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
      days.add(PlannerDayEntity(date: date, taskTitles: mockTasks[d] ?? []));
    }
    // Add a couple days from next month
    for (int d = 1; d <= 3; d++) {
      final date = DateTime(now.year, now.month + 1, d);
      days.add(PlannerDayEntity(date: date, taskTitles: []));
    }
    return days;
  }

  String _getMonthName(int month) {
    const names = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return names[month - 1];
  }

  Future<void> _refreshPlanner() async {
    setState(() {
      _today = DateTime.now();
      _days = _generateDays();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PlannerCubit>()..loadMonth(_currentMonth),
      child: Builder(
        builder: (context) {
          return Scaffold(
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
                          onPressed: () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (_) => const AddPlannerTaskBottomSheet(),
                            );
                            if (result == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã thêm công việc vào Inbox!'),
                                  backgroundColor: Color(0xFF0055FF),
                                ),
                              );
                              context.read<PlannerCubit>().loadMonth(_currentMonth);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz, color: Color(0xFF050505)),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (_) => PlannerOptionsBottomSheet(
                                onJumpToToday: () {
                                  final state = context.read<PlannerCubit>().state;
                                  if (state is PlannerLoaded) {
                                    final now = DateTime.now();
                                    final index = state.days.indexWhere((d) => 
                                        d.date.year == now.year && 
                                        d.date.month == now.month && 
                                        d.date.day == now.day);
                                    if (index != -1) {
                                      // Approximate height per row
                                      _scrollController.animateTo(
                                        index * 120.0, 
                                        duration: const Duration(milliseconds: 500), 
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }
                                },
                                onRefresh: () {
                                  context.read<PlannerCubit>().loadMonth(_currentMonth);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // ── Days List ────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshPlanner,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _days.length,
                  itemBuilder: (ctx, i) {
                    final day = _days[i];
                    final bool isToday =
                        day.date.year == _today.year &&
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
      ); // Scaffold
    }, // builder
    ), // Builder
    ); // BlocProvider
  }
}

