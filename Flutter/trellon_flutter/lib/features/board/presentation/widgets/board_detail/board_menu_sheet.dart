import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../../init_dependencies.dart';
import '../../../data/datasources/board_remote_data_source.dart';
import '../../cubit/board_detail_cubit.dart';
import '../../cubit/board_member_cubit.dart';
import 'board_members_sheet.dart';
import 'board_settings_sheet.dart';

class BoardMenuSheet extends StatelessWidget {
  final String boardId;
  final String boardName;

  const BoardMenuSheet({
    super.key,
    required this.boardId,
    required this.boardName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BoardMemberCubit(
        dataSource: serviceLocator<BoardRemoteDataSource>(),
        userLocalDataSource: serviceLocator<UserLocalDataSource>(),
      )..loadMembers(boardId),
      child: _BoardMenuSheetView(boardId: boardId, boardName: boardName),
    );
  }
}

class _BoardMenuSheetView extends StatelessWidget {
  final String boardId;
  final String boardName;

  const _BoardMenuSheetView({
    required this.boardId,
    required this.boardName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 7 / 8,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Menu bảng',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
          ),
          const Divider(),
          // Main Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTopIconButton(Icons.star_border, 'Đánh dấu sao'),
                _buildTopIconButton(Icons.group_outlined, 'Thành viên'),
                _buildTopIconButton(Icons.ios_share, 'Chia sẻ'),
                _buildTopIconButton(Icons.copy, 'Sao chép'),
                _buildTopIconButton(Icons.more_horiz, 'Thêm'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Members Section
                Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 16),
                    Text('Thành viên', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<BoardMemberCubit, BoardMemberState>(
                  builder: (context, state) {
                    List<Widget> avatarWidgets = [];
                    if (state is BoardMemberLoaded) {
                      for (var member in state.members.take(3)) {
                        avatarWidgets.add(
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: CachedNetworkImageProvider(member.resolvedAvatarUrl),
                            ),
                          ),
                        );
                      }
                      if (state.members.length > 3) {
                        avatarWidgets.add(
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[300],
                            child: Text('+${state.members.length - 3}', style: const TextStyle(fontSize: 12, color: Colors.black)),
                          ),
                        );
                      }
                    } else if (state is BoardMemberLoading) {
                      avatarWidgets.add(const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)));
                    }

                    return Row(
                      children: [
                        const SizedBox(width: 40), // indent
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => BoardMembersManageSheet(boardId: boardId, boardName: boardName),
                              );
                            },
                            child: Row(
                              children: [
                                ...avatarWidgets,
                                const Spacer(),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: ElevatedButton(
                    onPressed: () {
                        // Open direct invite logic if needed, or open member sheet
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => BoardMembersManageSheet(boardId: boardId, boardName: boardName),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('Mời...'),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                // Other Options
                _buildListTile(Icons.info_outline, 'Về bảng này'),
                _buildListTile(
                  Icons.settings, 
                  'Thiết lập bảng', 
                  onTap: () {
                    final cubit = context.read<BoardDetailCubit>();
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const BoardSettingsSheet(),
                      ),
                    );
                  },
                ),
                _buildListTile(Icons.campaign_outlined, 'Gửi phản hồi...'),
                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.checklist),
                  title: const Text('Trạng thái hoàn tất ở mặt trước thẻ'),
                  trailing: Switch(value: true, onChanged: (v) {}),
                ),
                _buildListTile(Icons.archive_outlined, 'Lưu trữ các thẻ được đánh dấu hoàn tất'),
                const Divider(),
                _buildListTile(Icons.power_outlined, 'Power-Ups', subtitle: 'Bình chọn, Thẻ bị "bỏ quên"...'),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Quản lý Power-Ups', style: TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {},
                  ),
                ),
                const Divider(),
                _buildListTile(Icons.history, 'Hoạt động'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIconButton(IconData icon, String tooltip) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

}
