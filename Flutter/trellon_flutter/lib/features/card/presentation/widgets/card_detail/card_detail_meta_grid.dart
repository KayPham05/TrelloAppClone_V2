import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/member_role_helper.dart';
import '../../../domain/entities/card_entity.dart';
import 'label_picker_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CardDetailMetaGrid extends StatelessWidget {
  final List<CardMemberEntity> members;
  final List<CardLabelEntity> labels;
  final DateTime? dueDate;
  final VoidCallback onAddMember;
  final Function(CardMemberEntity, String) onMemberRoleChanged;
  final Function(CardMemberEntity) onRemoveMember;
  final VoidCallback onAddLabel;
  final Function(DateTime) onDateChanged;

  const CardDetailMetaGrid({
    super.key,
    required this.members,
    required this.labels,
    this.dueDate,
    required this.onAddMember,
    required this.onMemberRoleChanged,
    required this.onRemoveMember,
    required this.onAddLabel,
    required this.onDateChanged,
  });

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
                        GestureDetector(
                          onTap: onAddMember,
                          child: _buildAddButton(label: 'THÊM'),
                        )
                      else ...[
                        for (int i = 0; i < (members.length > 5 ? 5 : members.length); i++)
                          _buildMemberAvatar(context, members[i], overlap: i > 0),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onAddMember,
                          child: _buildAddButton(label: members.length > 5 ? '+${members.length - 5}' : null),
                        ),
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
                ...labels.map((l) {
                  final color = _parseHexColor(l.colorCode);
                  return _buildLabelChip(l.title, color.withValues(alpha: 0.2), color);
                }),
                GestureDetector(
                  onTap: onAddLabel,
                  child: _buildAddButton(isSmall: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Due Date (Lịch trình)
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dueDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              );
              if (date != null) {
                onDateChanged(date);
              }
            },
            child: _buildMetaSection(
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
                        'Hôm nay',
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

  Widget _buildMemberAvatar(BuildContext context, CardMemberEntity member, {bool overlap = false}) {
    final roleColor = MemberRoleHelper.colorForRole(member.role);
    
    Widget avatar = PopupMenuButton<String>(
      tooltip: '${member.userName} (${member.role})',
      onSelected: (action) {
        if (action == 'remove') {
          onRemoveMember(member);
        } else {
          onMemberRoleChanged(member, action);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(member.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'Assignee', child: Text('Assignee')),
        const PopupMenuItem(value: 'Reviewer', child: Text('Reviewer')),
        const PopupMenuItem(value: 'Observer', child: Text('Observer')),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'remove',
          child: Text('Gỡ khỏi thẻ', style: TextStyle(color: Colors.red)),
        ),
      ],
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
          boxShadow: [
            BoxShadow(
              color: roleColor.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: CachedNetworkImage(
            imageUrl: member.resolvedAvatarUrl,
            fit: BoxFit.cover,
            placeholder: (ctx, url) => Container(color: roleColor),
          ),
        ),
      ),
    );

    if (overlap) {
      return Align(
        widthFactor: 0.7,
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
    final bool hasText = text.isNotEmpty;
    return Container(
      padding: hasText 
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: hasText ? null : const BoxConstraints(minWidth: 40, minHeight: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: hasText 
          ? Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.5,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Color _parseHexColor(String hexString) {
    if (hexString.isEmpty) return Colors.grey;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    int? colorValue = int.tryParse(buffer.toString(), radix: 16);
    return colorValue != null ? Color(colorValue) : Colors.grey;
  }
}
