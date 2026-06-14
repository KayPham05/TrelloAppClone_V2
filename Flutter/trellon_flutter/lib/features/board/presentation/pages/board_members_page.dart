import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../core/utils/member_role_helper.dart';
import '../../../../init_dependencies.dart';
import '../cubit/board_member_cubit.dart';
import '../../domain/entities/board_member.dart';
import '../../../../core/services/authorization_service.dart';
import '../../data/datasources/board_remote_data_source.dart';
import '../../../member_invite/domain/usecases/search_invite_suggestions_usecase.dart';
import '../../../member_invite/presentation/widgets/member_invite_picker.dart';

class BoardMembersPage extends StatelessWidget {
  final String boardId;
  final String boardName;
  final String? workspaceId;

  const BoardMembersPage({
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
      child: _BoardMembersView(
        boardId: boardId,
        boardName: boardName,
        workspaceId: workspaceId,
      ),
    );
  }
}

class _BoardMembersView extends StatelessWidget {
  final String boardId;
  final String boardName;
  final String? workspaceId;
  final _authService = AuthorizationService();
  _BoardMembersView({
    required this.boardId,
    required this.boardName,
    this.workspaceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thành viên bảng',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              boardName,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<BoardMemberCubit, BoardMemberState>(
            builder: (context, state) {
              final canInvite =
                  state is BoardMemberLoaded &&
                  _authService.canInviteToBoard(state.currentUserRole, null);
              if (!canInvite) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showAddMemberDialog(context),
                icon: const Icon(Icons.person_add_rounded),
                color: AppColors.primary,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BoardMemberCubit, BoardMemberState>(
        builder: (context, state) {
          if (state is BoardMemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BoardMemberError) {
            return Center(child: Text(state.message));
          }
          if (state is BoardMemberLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.members.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final member = state.members[index];
                final canManageThisBoard = _authService.canManageBoard(
                  state.currentUserRole,
                  null,
                );

                final canModifyThisMember =
                    canManageThisBoard && member.role != 'Owner';

                return _MemberListItem(
                  member: member,
                  canManage: canManageThisBoard,
                  onUpdateRole: canModifyThisMember
                      ? () => _showUpdateRoleDialog(context, member)
                      : null,
                  onRemove: canModifyThisMember
                      ? () => _confirmRemove(context, member)
                      : null,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
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
              workspaceId: workspaceId,
              boardId: boardId,
            );
          },
          onSubmit: (selected) => cubit.addMembers(
            boardId: boardId,
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Đổi quyền — ${member.userName}'),
        content: StatefulBuilder(
          builder: (ctx, setS) => DropdownButtonFormField<String>(
            initialValue: selectedRole,
            items: MemberRoleHelper.rolesForScope(MemberScope.board)
                .where((r) => r != 'Owner')
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setS(() => selectedRole = v ?? selectedRole),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await cubit.updateRole(
                boardId: boardId,
                userId: member.userUId,
                newRole: selectedRole,
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, BoardMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text('Xóa "${member.userName}" khỏi board này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<BoardMemberCubit>().removeMember(
                boardId: boardId,
                userId: member.userUId,
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _MemberListItem extends StatelessWidget {
  final BoardMember member;
  final bool canManage;
  final VoidCallback? onUpdateRole;
  final VoidCallback? onRemove;

  const _MemberListItem({
    required this.member,
    required this.canManage,
    this.onUpdateRole,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = MemberRoleHelper.colorForRole(member.role);
    final roleIcon = MemberRoleHelper.iconForRole(member.role);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(member.resolvedAvatarUrl),
        ),
        title: Text(
          member.userName,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(member.email, style: GoogleFonts.inter(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(roleIcon, size: 12, color: roleColor),
                  const SizedBox(width: 4),
                  Text(
                    member.role,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ],
              ),
            ),
            if (canManage && (onUpdateRole != null || onRemove != null))
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'role') onUpdateRole?.call();
                  if (v == 'remove') onRemove?.call();
                },
                itemBuilder: (_) => [
                  if (onUpdateRole != null)
                    const PopupMenuItem(
                      value: 'role',
                      child: Text('Đổi quyền'),
                    ),
                  if (onRemove != null)
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text(
                        'Xóa khỏi board',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
