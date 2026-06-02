import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../domain/entities/card_entity.dart';

class CardMemberPickerSheet extends StatefulWidget {
  final List<CardMemberEntity> allBoardMembers;
  final List<CardMemberEntity> currentCardMembers;
  final Function(CardMemberEntity) onMemberToggled;
  final bool canManage;

  const CardMemberPickerSheet({
    super.key,
    required this.allBoardMembers,
    required this.currentCardMembers,
    required this.onMemberToggled,
    this.canManage = true,
  });

  @override
  State<CardMemberPickerSheet> createState() => _CardMemberPickerSheetState();

  static void show(
    BuildContext context, {
    required List<CardMemberEntity> allBoardMembers,
    required List<CardMemberEntity> currentCardMembers,
    required Function(CardMemberEntity) onMemberToggled,
    bool canManage = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.875,
        child: CardMemberPickerSheet(
          allBoardMembers: allBoardMembers,
          currentCardMembers: currentCardMembers,
          onMemberToggled: onMemberToggled,
          canManage: canManage,
        ),
      ),
    );
  }
}

class _CardMemberPickerSheetState extends State<CardMemberPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CardMemberEntity> _filteredMembers = [];
  late List<String> _localAssignedIds;

  @override
  void initState() {
    super.initState();
    _filteredMembers = widget.allBoardMembers;
    _localAssignedIds = widget.currentCardMembers.map((m) => m.userUId).toList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = widget.allBoardMembers.where((m) {
        final nameMatch = m.userName.toLowerCase().contains(query);
        final emailMatch = m.email.toLowerCase().contains(query);
        return nameMatch || emailMatch;
      }).toList();
    });
  }

  bool _isMember(String userUId) => _localAssignedIds.contains(userUId);

  void _toggleLocalMember(CardMemberEntity member) {
    setState(() {
      if (_localAssignedIds.contains(member.userUId)) {
        _localAssignedIds.remove(member.userUId);
      } else {
        _localAssignedIds.add(member.userUId);
      }
    });
    widget.onMemberToggled(member);
  }

  String _extractUsername(String email) {
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero, // reset padding to center icon
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                const Text(
                  'Thành viên',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100] ?? const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_filteredMembers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Không tìm thấy thành viên nào.',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          // Member List
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              shrinkWrap: true,
              itemCount: _filteredMembers.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, endIndent: 16, color: AppColors.surfaceVariant),
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                final isAssigned = _isMember(member.userUId);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(member.resolvedAvatarUrl),
                  ),
                  title: Text(
                    member.userName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '@${_extractUsername(member.email)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  trailing: isAssigned
                      ? const Icon(Icons.check, color: AppColors.primaryContainer) // blue check
                      : null,
                  onTap: widget.canManage
                      ? () => _toggleLocalMember(member)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
