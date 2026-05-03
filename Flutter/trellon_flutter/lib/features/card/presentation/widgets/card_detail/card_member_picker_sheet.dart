import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/member_role_helper.dart';
import '../../../domain/entities/card_entity.dart';

class CardMemberPickerSheet extends StatelessWidget {
  final List<CardMemberEntity> allBoardMembers;
  final List<CardMemberEntity> currentCardMembers;
  final Function(CardMemberEntity) onMemberToggled;

  const CardMemberPickerSheet({
    super.key,
    required this.allBoardMembers,
    required this.currentCardMembers,
    required this.onMemberToggled,
  });

  bool _isMember(String userUId) =>
      currentCardMembers.any((m) => m.userUId == userUId);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Thành viên bảng',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (allBoardMembers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Không có thành viên nào khác trong board.',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
              ),
            ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: allBoardMembers.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final member = allBoardMembers[index];
                final isAssigned = _isMember(member.userUId);
                final roleColor = MemberRoleHelper.colorForRole(member.role);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(member.resolvedAvatarUrl),
                  ),
                  title: Text(
                    member.userName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        member.email,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.role,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: isAssigned
                        ? const Icon(Icons.check_circle_rounded,
                            color: Colors.green)
                        : const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.outline),
                  ),
                  onTap: () => onMemberToggled(member),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required List<CardMemberEntity> allBoardMembers,
    required List<CardMemberEntity> currentCardMembers,
    required Function(CardMemberEntity) onMemberToggled,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: CardMemberPickerSheet(
          allBoardMembers: allBoardMembers,
          currentCardMembers: currentCardMembers,
          onMemberToggled: onMemberToggled,
        ),
      ),
    );
  }
}
