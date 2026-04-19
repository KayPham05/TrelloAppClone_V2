import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/card_entity.dart';

class CardDetailMetaGrid extends StatelessWidget {
  final List<CardMemberEntity> members;
  final DateTime? dueDate;
  const CardDetailMetaGrid({super.key, required this.members, this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Members
              Expanded(
                flex: 4,
                child: _buildMetaSection(
                  title: 'THÀNH VIÊN',
                  content: Row(
                    children: [
                      if(members.isEmpty)
                        _buildAddButton(label: 'THÊM')
                      else ...[
                        for (int i = 0; i < (members.length > 3 ? 3 : members.length); i++)
                          _buildAvatar(
                            (members[i].userName ?? 'U').substring(0, 1),
                            const Color(0xFF1E293B),
                            const Color(0xFF94A3B8),
                            overlap: i > 0,
                          ),
                        const SizedBox(width: 8),
                        _buildAddButton(label: members.length > 3 ? '+${members.length - 3}' : null),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Labels
          _buildMetaSection(
            title: 'NHÃN',
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildLabelChip('DESIGN', const Color(0xFFDBEAFE),
                    const Color(0xFF1D4ED8)), // light blue
                _buildLabelChip('URGENT', const Color(0xFFF3E8FF),
                    const Color(0xFF7E22CE)), // light purple
                _buildAddButton(isSmall: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Due Date (Lịch trình)
          _buildMetaSection(
            title: 'LỊCH TRÌNH',
            icon: Icons.calendar_today_rounded,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày bắt đầu',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '12 Tháng 10, 2023',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày hết hạn',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      dueDate != null ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}' : 'Chưa thiết lập',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dueDate == null ? AppColors.onSurfaceVariant : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetaSection({
    required String title,
    required Widget content,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon ?? Icons.local_offer_rounded,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildAvatar(String initial, Color color, Color textColor,
      {bool overlap = false}) {
    Widget avatar = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );

    if (overlap) {
      return Align(
        widthFactor: 0.75, // 32 * 0.75 = 24. Shift 8px left.
        alignment: Alignment.centerRight,
        child: avatar,
      );
    }
    return avatar;
  }

  Widget _buildAddButton({String? label, bool isSmall = false}) {
    final size = isSmall ? 28.0 : 32.0;
    return Container(
      width: label != null ? null : size,
      height: size,
      padding: label != null ? const EdgeInsets.symmetric(horizontal: 10) : null,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: Alignment.center,
      child: label != null
          ? Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D4ED8),
              ),
            )
          : Icon(Icons.add, size: 16, color: AppColors.onSurfaceVariant),
    );
  }

  Widget _buildLabelChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
