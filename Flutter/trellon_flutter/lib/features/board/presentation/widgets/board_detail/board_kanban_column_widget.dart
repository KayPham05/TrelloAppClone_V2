import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/list_entity.dart';
import '../list_menu_bottom_sheet.dart';
class KanbanColumnWidget extends StatelessWidget {
  final ListEntity list;
  final int columnIndex;
  final double scale;
  final Widget header;
  final Widget Function(int) itemBuilder;
  final Widget addCardButton;

  const KanbanColumnWidget({
    super.key,
    required this.list,
    required this.columnIndex,
    required this.scale,
    required this.header,
    required this.itemBuilder,
    required this.addCardButton,
  });

  @override
  Widget build(BuildContext context) {
    final double colWidth = 280.0 * scale;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: colWidth,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: columnIndex,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: header,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              itemCount: list.cards.length * 2 + 1,
              itemBuilder: (_, index) => itemBuilder(index),
            ),
          ),
          addCardButton,
        ],
      ),
    );
  }
}

class KanbanColumnHeaderWidget extends StatelessWidget {
  final ListEntity list;
  final double scale;

  const KanbanColumnHeaderWidget({
    super.key,
    required this.list,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(14 * scale, 14 * scale, 8 * scale, 10 * scale),
      child: Row(
        children: [
          Expanded(
            child: Text(
              list.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: 0.8 * scale,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.surfaceContainerLow,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                builder: (context) => ListMenuBottomSheet(list: list),
              );
            },
            child: Icon(
              Icons.more_horiz_rounded,
              size: 22 * scale,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
