import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/list_entity.dart';
import '../list_menu_bottom_sheet.dart';

// ── Normal Kanban Column (Reorderable horizontal scroll mode) ────────────────
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

// ── Zoom Mode Column ─────────────────────────────────────────────────────────
/// Used in swipe/zoom (PageView) mode.
/// - [columnWidth]: passed externally (= 80% of screen width)
/// - Height is responsive to card count, capped at 80% of screen height.
/// - Cards are scrollable inside the capped-height column.
class KanbanColumnZoomWidget extends StatelessWidget {
  final ListEntity list;
  final double columnWidth;
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final VoidCallback onAddCard;

  const KanbanColumnZoomWidget({
    super.key,
    required this.list,
    required this.columnWidth,
    required this.itemCount,
    required this.itemBuilder,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    final double maxColumnH = MediaQuery.of(context).size.height * 0.80;

    return Container(
      width: columnWidth,
      constraints: BoxConstraints(maxHeight: maxColumnH),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomColumnHeader(list: list),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 4),
              physics: const ClampingScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) => itemBuilder(index),
            ),
          ),
          _ZoomAddCardButton(onTap: onAddCard),
        ],
      ),
    );
  }
}

class _ZoomColumnHeader extends StatelessWidget {
  final ListEntity list;
  const _ZoomColumnHeader({required this.list});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              list.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: 0.8,
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
            child: const Icon(
              Icons.more_horiz_rounded,
              size: 22,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomAddCardButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ZoomAddCardButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            const Icon(Icons.add_rounded, size: 18, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Thêm thẻ',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Normal Column Header (used by normal mode) ───────────────────────────────
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
