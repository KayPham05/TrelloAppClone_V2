import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../card/domain/entities/card_entity.dart';
import '../../../../../core/constants/app_colors.dart';
class KanbanCardUiWidget extends StatelessWidget {
  final CardEntity card;
  final String boardId;
  final double scale;
  final bool elevated;
  final VoidCallback onTap;

  const KanbanCardUiWidget({
    super.key,
    required this.card,
    required this.boardId,
    required this.scale,
    this.elevated = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: EdgeInsets.fromLTRB(8 * scale, 0, 8 * scale, 0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8 * scale),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 14 * scale,
                    offset: Offset(0, 6 * scale),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0x0F191C1E),
                    blurRadius: 4 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
        ),
        padding: EdgeInsets.all(12 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover image
            if (card.backgroundUrl != null && card.backgroundUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6 * scale),
                  child: CachedNetworkImage(
                    imageUrl: card.backgroundUrl!,
                    width: double.infinity,
                    height: 80 * scale,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Labels
            if (card.labels.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 6 * scale),
                child: Wrap(
                  spacing: 4 * scale,
                  runSpacing: 4 * scale,
                  children: card.labels.map((l) {
                    Color color;
                    if (l.colorCode.isNotEmpty) {
                      final buffer = StringBuffer();
                      if (l.colorCode.length == 6 || l.colorCode.length == 7) buffer.write('ff');
                      buffer.write(l.colorCode.replaceFirst('#', ''));
                      color = Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFF9E9E9E);
                    } else {
                      color = Colors.grey;
                    }
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                      constraints: BoxConstraints(minWidth: 32 * scale, minHeight: 8 * scale),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4 * scale),
                      ),
                      child: l.title.isNotEmpty
                          ? Text(
                              l.title,
                              style: GoogleFonts.inter(
                                fontSize: 10 * scale,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }).toList(),
                ),
              ),
            Text(
              card.title,
              style: GoogleFonts.inter(
                fontSize: 14.0 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
                height: 1.35,
              ),
            ),
            if (card.dueDate != null ||
                (card.description != null && card.description!.isNotEmpty) ||
                card.comments.isNotEmpty ||
                card.fileUrls.isNotEmpty ||
                card.todoItems.isNotEmpty ||
                card.members.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 6 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 8 * scale,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (card.dueDate != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_rounded, size: 12 * scale, color: AppColors.onSurfaceVariant),
                              SizedBox(width: 4 * scale),
                              Text('${card.dueDate!.day}/${card.dueDate!.month}',
                                  style: GoogleFonts.inter(fontSize: 11 * scale, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        if (card.description != null && card.description!.isNotEmpty)
                          Icon(Icons.subject_rounded, size: 12 * scale, color: AppColors.onSurfaceVariant),
                        if (card.comments.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, size: 12 * scale, color: AppColors.onSurfaceVariant),
                              SizedBox(width: 3 * scale),
                              Text('${card.comments.length}',
                                  style: GoogleFonts.inter(fontSize: 11 * scale, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        if (card.fileUrls.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.attach_file_rounded, size: 12 * scale, color: AppColors.onSurfaceVariant),
                              SizedBox(width: 3 * scale),
                              Text('${card.fileUrls.length}',
                                  style: GoogleFonts.inter(fontSize: 11 * scale, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        if (card.todoItems.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_box_outlined, size: 12 * scale, color: AppColors.onSurfaceVariant),
                              SizedBox(width: 3 * scale),
                              Text(
                                  '${card.todoItems.where((t) => t.isCompleted).length}/${card.todoItems.length}',
                                  style: GoogleFonts.inter(fontSize: 11 * scale, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                      ],
                    ),
                    if (card.members.isNotEmpty)
                      Row(
                        children: card.members.take(3).map((m) {
                          return Padding(
                            padding: EdgeInsets.only(left: 4 * scale),
                            child: CircleAvatar(
                              radius: 10 * scale,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                (m.userName ?? 'U').substring(0, 1),
                                style: GoogleFonts.inter(
                                    fontSize: 9 * scale, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddCardButtonWidget extends StatelessWidget {
  final double scale;
  final VoidCallback onTap;

  const AddCardButtonWidget({
    super.key,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(8 * scale, 4 * scale, 8 * scale, 8 * scale),
        padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 8 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * scale),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(Icons.add_rounded, size: 18 * scale, color: AppColors.onSurfaceVariant),
            SizedBox(width: 6 * scale),
            Text(
              'Thêm thẻ',
              style: GoogleFonts.inter(
                fontSize: 13 * scale,
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
