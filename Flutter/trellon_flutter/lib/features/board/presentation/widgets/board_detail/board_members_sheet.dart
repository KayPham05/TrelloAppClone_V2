import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../../core/utils/member_role_helper.dart';
import '../../../../../core/services/authorization_service.dart';
import '../../../../../init_dependencies.dart';
import '../../../../member_invite/domain/usecases/search_invite_suggestions_usecase.dart';
import '../../../../member_invite/presentation/widgets/member_invite_picker.dart';
import '../../../data/datasources/board_remote_data_source.dart';
import '../../cubit/board_member_cubit.dart';
import '../../../domain/entities/board_member.dart';

class BoardMembersManageSheet extends StatelessWidget {
  final String boardId;
  final String boardName;
  final String? workspaceId;

  const BoardMembersManageSheet({
    super.key,
    required this.boardId,
    required this.boardName,
    this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BoardMemberCubit(
        dataSource: serviceLocator<BoardRemoteDataSource>(),
        userLocalDataSource: serviceLocator<UserLocalDataSource>(),
      )..loadMembers(boardId),
      child: _BoardMembersManageSheetView(
        boardId: boardId,
        boardName: boardName,
        workspaceId: workspaceId,
      ),
    );
  }
}

class _BoardMembersManageSheetView extends StatefulWidget {
  final String boardId;
  final String boardName;
  final String? workspaceId;

  const _BoardMembersManageSheetView({
    required this.boardId,
    required this.boardName,
    this.workspaceId,
  });

  @override
  State<_BoardMembersManageSheetView> createState() =>
      _BoardMembersManageSheetViewState();
}

class _BoardMembersManageSheetViewState
    extends State<_BoardMembersManageSheetView> {
  final _authService = AuthorizationService();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Top handling bar
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
                    'Quản lý thành viên bảng thông tin',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Spacer
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Invite Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.boardName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sẽ mời với tư cách thành viên',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMemberDialog(context),
                    icon: const Icon(
                      Icons.ios_share,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Mời',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: BlocBuilder<BoardMemberCubit, BoardMemberState>(
              builder: (context, state) {
                if (state is BoardMemberLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is BoardMemberError) {
                  return Center(child: Text(state.message));
                }
                if (state is BoardMemberLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Các thành viên bảng (${state.members.length})',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.members.length,
                          itemBuilder: (context, index) {
                            final member = state.members[index];
                            final canManageThisBoard = _authService
                                .canManageBoard(state.currentUserRole, null);
                            final canModifyThisMember =
                                canManageThisBoard && member.role != 'Owner';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                  member.resolvedAvatarUrl,
                                  cacheKey: 'avatar_${member.userUId}',
                                ),
                              ),
                              title: Text(
                                member.userName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                member.email,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: canModifyThisMember
                                    ? () =>
                                          _showUpdateRoleDialog(context, member)
                                    : null,
                                child: Text(
                                  member.role,
                                  style: TextStyle(
                                    color: canModifyThisMember
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Bottom Search Input mimicking Add
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () => _showAddMemberDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mời bằng tên, tên người dùng hoặc email',
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final cubit = context.read<BoardMemberCubit>();
    final searchUseCase = serviceLocator<SearchInviteSuggestionsUseCase>();
    String selectedRole = 'Editor';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setSheetState) => MemberInvitePicker(
          title: 'Mời thành viên vào bảng',
          roleControl: DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: const InputDecoration(
              labelText: 'Vai trò',
              border: OutlineInputBorder(),
            ),
            items: MemberRoleHelper.rolesForScope(MemberScope.board)
                .where((role) => role != 'Owner')
                .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                .toList(),
            onChanged: (value) =>
                setSheetState(() => selectedRole = value ?? selectedRole),
          ),
          searchSuggestions: ({required query, required selected}) async {
            final requesterUId =
                await serviceLocator<UserLocalDataSource>().getUserId() ?? '';
            return searchUseCase(
              query: query,
              scope: 'board',
              requesterUId: requesterUId,
              workspaceId: widget.workspaceId,
              boardId: widget.boardId,
            );
          },
          onSubmit: (selected) => cubit.addMembers(
            boardId: widget.boardId,
            userIds: selected.map((user) => user.userUId).toList(),
            role: selectedRole,
          ),
        ),
      ),
    );
  }

  void _showUpdateRoleDialog(BuildContext context, BoardMember member) {
    final cubit = context.read<BoardMemberCubit>();
    String selectedRole = member.role;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đổi quyền — ${member.userName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: MemberRoleHelper.rolesForScope(MemberScope.board)
                  .where((r) => r != 'Owner')
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => selectedRole = v ?? selectedRole,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await cubit.updateRole(
                        boardId: widget.boardId,
                        userId: member.userUId,
                        newRole: selectedRole,
                      );
                    },
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await cubit.removeMember(
                    boardId: widget.boardId,
                    userId: member.userUId,
                  );
                },
                child: const Text(
                  'Xoá khỏi bảng',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
