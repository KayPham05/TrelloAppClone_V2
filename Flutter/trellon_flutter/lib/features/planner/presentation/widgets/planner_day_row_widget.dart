import 'package:flutter/material.dart';
import '../../domain/entities/planner_entity.dart';
import '../../../card/presentation/pages/card_detail_page.dart';
import '../../../card/domain/entities/card_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/planner_cubit.dart';
import 'add_planner_task_bottom_sheet.dart';

class PlannerDayRowWidget extends StatelessWidget {
  final PlannerDayEntity day;
  final bool isToday;
  final bool isLast;
  final DateTime plannerMonth;

  const PlannerDayRowWidget({
    super.key,
    required this.day,
    required this.isToday,
    required this.isLast,
    required this.plannerMonth,
  });

  String _getShortWeekday(int weekday) {
    const days = ['Th 2','Th 3','Th 4','Th 5','Th 6','Th 7','CN'];
    return days[weekday - 1];
  }

  Color _getCardColor(String id) {
    // Miro pastel colors
    const colors = [
      Color(0xFFFFF2B2), // Soft Yellow
      Color(0xFFFFE0D9), // Coral Light
      Color(0xFFD9F4F0), // Teal Light
      Color(0xFFFFE4EE), // Rose Light
      Color(0xFFE4F0FF), // Blue Light
    ];
    final hash = id.hashCode;
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final weekday = _getShortWeekday(day.date.weekday);
    final accentColor = const Color(0xFF0055FF); // Miro Action Blue for today

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date circle
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Text(
                      weekday,
                      style: TextStyle(
                        color: isToday ? accentColor : const Color(0xFF6B6D76), // Slate
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? accentColor : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.date.day}',
                        style: TextStyle(
                          color: isToday ? Colors.white : const Color(0xFF050505), // Ink
                          fontSize: 16,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Tasks or empty state
              Expanded(
                child: DragTarget<CardEntity>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    final card = details.data;
                    context.read<PlannerCubit>().updateCardDate(card.id, day.date, plannerMonth);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return Container(
                      decoration: BoxDecoration(
                        color: isHovering ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isHovering ? Border.all(color: Colors.blue.withValues(alpha: 0.3)) : null,
                      ),
                      padding: EdgeInsets.all(isHovering ? 4 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (day.hasTask)
                            ...day.cards.map((card) {
                              Widget cardWidget = GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CardDetailPage(card: card, boardId: null),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _getCardColor(card.id),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  ),
                                  child: Text(
                                    card.title,
                                    style: const TextStyle(
                                      color: Color(0xFF050505), // Ink Deep
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: LongPressDraggable<CardEntity>(
                                  data: card,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width - 90, // Approximate width
                                      child: Opacity(
                                        opacity: 0.8,
                                        child: cardWidget,
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: cardWidget,
                                  ),
                                  child: cardWidget,
                                ),
                              );
                            })
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Chưa lên kế hoạch nào',
                                style: TextStyle(
                                  color: const Color(0xFF6B6D76).withValues(alpha: 0.6), // Slate
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => AddPlannerTaskBottomSheet(selectedDate: day.date),
                        );
                        
                        if (result == true && context.mounted) {
                          context.read<PlannerCubit>().loadMonth(plannerMonth);
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 16, color: Color(0xFF6B6D76)),
                            const SizedBox(width: 4),
                            const Text(
                              'Thêm công việc',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B6D76),
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
        // Today separator line
        if (isToday)
          Container(height: 2, color: accentColor),
        if (!isToday && !isLast)
          Container(height: 1, margin: const EdgeInsets.only(left: 64), color: const Color(0xFFE5E5E5)), // Hairline Soft
      ],
    );
  }
}
