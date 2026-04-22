import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
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

  bool _isMember(String userUId) => currentCardMembers.any((m) => m.userUId == userUId);

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
        children: [
          Text(
            'Thành viên bảng',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (allBoardMembers.isEmpty)
             Padding(
               padding: const EdgeInsets.all(20),
               child: Text('Không có thành viên nào khác.', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
             ),
          ...allBoardMembers.map((member) {
            final isAssigned = _isMember(member.userUId);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  (member.userName ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text(
                member.userName ?? 'User',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              trailing: isAssigned 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.add_circle_outline, color: AppColors.outline),
              onTap: () => onMemberToggled(member),
            );
          }),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CardMemberPickerSheet(
        allBoardMembers: allBoardMembers,
        currentCardMembers: currentCardMembers,
        onMemberToggled: onMemberToggled,
      ),
    );
  }
}
