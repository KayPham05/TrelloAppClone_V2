import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/member_role_helper.dart';
import '../../../domain/entities/card_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Flat list-row style meta sections: Labels, Members, Dates
/// Matching the reference design (simple rows with icon + content, minimal padding)
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
    return Column(
      children: [
        // ── Description row (placeholder, will be replaced by CardDetailDescription below)
        // ── Labels row ─────────────────────────────────────────────────
        _SectionRow(
          icon: Icons.label_outline_rounded,
          child: labels.isEmpty
              ? GestureDetector(
                  onTap: onAddLabel,
                  child: const _AddChip(),
                )
              : GestureDetector(
                  onTap: onAddLabel,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...labels.map((l) => _LabelChip(label: l)),
                      const _AddChip(small: true),
                    ],
                  ),
                ),
        ),
        const Divider(height: 1, indent: 48),

        // ── Members row ────────────────────────────────────────────────
        _SectionRow(
          icon: Icons.person_outline_rounded,
          child: GestureDetector(
            onTap: onAddMember,
            child: members.isEmpty
                ? const _AddChip()
                : Row(
                    children: [
                      for (int i = 0;
                          i < (members.length > 5 ? 5 : members.length);
                          i++)
                        _MemberAvatar(
                          member: members[i],
                          overlap: i > 0,
                          onMemberRoleChanged: onMemberRoleChanged,
                          onRemoveMember: onRemoveMember,
                        ),
                      const SizedBox(width: 8),
                      if (members.length > 5)
                        Text('+${members.length - 5}',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.grey)),
                    ],
                  ),
          ),
        ),
        const Divider(height: 1, indent: 48),

        // ── Start date row ─────────────────────────────────────────────
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: dueDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (date != null) onDateChanged(date);
          },
          child: _SectionRow(
            icon: Icons.access_time_rounded,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ngày bắt đầu',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.onSurface)),
                Text('Hôm nay',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),

        // ── Due date row ───────────────────────────────────────────────
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: dueDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (date != null) onDateChanged(date);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(48, 0, 16, 0),
            child: SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ngày hết hạn',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.onSurface)),
                    Text(
                      dueDate != null
                          ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                          : 'Chưa thiết lập',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: dueDate == null
                              ? AppColors.onSurfaceVariant
                              : const Color(0xFFB91C1C),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section row (icon + content) ──────────────────────────────────────────────
class _SectionRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _SectionRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ── Label chip ────────────────────────────────────────────────────────────────
class _LabelChip extends StatelessWidget {
  final CardLabelEntity label;
  const _LabelChip({required this.label});

  Color _parseColor(String hex) {
    final buf = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buf.write('ff');
    buf.write(hex.replaceFirst('#', ''));
    return Color(int.tryParse(buf.toString(), radix: 16) ?? 0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(label.colorCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.title,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  final bool small;
  const _AddChip({this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: small ? 28 : null,
      height: small ? 28 : 32,
      padding:
          small ? null : const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.add, size: small ? 14 : 16, color: Colors.grey.shade600),
    );
  }
}

// ── Member avatar ─────────────────────────────────────────────────────────────
class _MemberAvatar extends StatelessWidget {
  final CardMemberEntity member;
  final bool overlap;
  final Function(CardMemberEntity, String) onMemberRoleChanged;
  final Function(CardMemberEntity) onRemoveMember;
  const _MemberAvatar({
    required this.member,
    required this.overlap,
    required this.onMemberRoleChanged,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
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
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Text(member.userName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'Assignee', child: Text('Assignee')),
        const PopupMenuItem(value: 'Reviewer', child: Text('Reviewer')),
        const PopupMenuItem(value: 'Observer', child: Text('Observer')),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: 'remove',
            child: Text('Gỡ khỏi thẻ',
                style: TextStyle(color: Colors.red))),
      ],
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: AppColors.surfaceContainerLowest, width: 2),
          color: roleColor,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: member.resolvedAvatarUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: roleColor),
          ),
        ),
      ),
    );
    if (overlap) {
      return Align(widthFactor: 0.7, child: avatar);
    }
    return avatar;
  }
}
