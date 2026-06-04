import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../init_dependencies.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';
import '../../../inbox/presentation/bloc/inbox_cubit.dart';
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

  Future<void> _refreshPlanner(BuildContext context) async {
    context.read<PlannerCubit>().loadMonth(_currentMonth);
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
                          child: InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _currentMonth,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                helpText: 'Chọn tháng (chọn 1 ngày bất kỳ)',
                              );
                              if (pickedDate != null && context.mounted) {
                                setState(() {
                                  _currentMonth = DateTime(pickedDate.year, pickedDate.month, 1);
                                });
                                context.read<PlannerCubit>().loadMonth(_currentMonth);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getMonthName(_currentMonth.month),
                                  style: const TextStyle(
                                    color: Color(0xFF050505), // Miro Ink Deep
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600, // Slightly bolder for Miro headings
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: Color(0xFF050505), size: 28),
                              ],
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
                              builder: (_) => AddPlannerTaskBottomSheet(selectedDate: DateTime.now()),
                            );
                            if (result == true) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã thêm công việc vào Inbox!'),
                                    backgroundColor: Color(0xFF0055FF),
                                  ),
                                );
                                context.read<PlannerCubit>().loadMonth(_currentMonth);
                              }
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
                  // ── Days List ────────────────────────────────────────────────
                  Expanded(
                    child: BlocBuilder<PlannerCubit, PlannerState>(
                      builder: (context, state) {
                        if (state is PlannerLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is PlannerError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(state.message, style: const TextStyle(color: Colors.red)),
                                TextButton(
                                  onPressed: () => context.read<PlannerCubit>().loadMonth(_currentMonth),
                                  child: const Text("Thử lại"),
                                ),
                              ],
                            ),
                          );
                        } else if (state is PlannerLoaded) {
                          final today = DateTime.now();
                          return RefreshIndicator(
                            onRefresh: () => _refreshPlanner(context),
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.days.length,
                              itemBuilder: (ctx, i) {
                                final day = state.days[i];
                                final bool isToday =
                                    day.date.year == today.year &&
                                    day.date.month == today.month &&
                                    day.date.day == today.day;
                                final bool isLast = i == state.days.length - 1;

                                return PlannerDayRowWidget(
                                  day: day,
                                  isToday: isToday,
                                  isLast: isLast,
                                  plannerMonth: _currentMonth,
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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

