import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../core/utils/member_role_helper.dart';
import '../../../../init_dependencies.dart';
import '../cubit/workspace_member_cubit.dart';
import '../../domain/entities/workspace_member.dart';
import '../../../../core/services/authorization_service.dart';

class WorkspaceMembersPage extends StatelessWidget {
  final String workspaceId;
  final String workspaceName;

  const WorkspaceMembersPage({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorkspaceMemberCubit(
        client: serviceLocator<Dio>(),
        userLocalDataSource: serviceLocator<UserLocalDataSource>(),
      )..loadMembers(workspaceId),
      child: _WorkspaceMembersView(
        workspaceId: workspaceId,
        workspaceName: workspaceName,
      ),
    );
  }
}

class _WorkspaceMembersView extends StatelessWidget {
  final String workspaceId;
  final String workspaceName;
  final _authService = AuthorizationService();
  _WorkspaceMembersView({
    required this.workspaceId,
    required this.workspaceName,
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
              'Thành viên',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              workspaceName,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<WorkspaceMemberCubit, WorkspaceMemberState>(
            builder: (context, state) {
              final canInvite = state is WorkspaceMemberLoaded &&
                  _authService.canInviteToWorkspace(state.currentUserRole);
              if (!canInvite) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _showInviteDialog(context),
                icon: const Icon(Icons.person_add_rounded),
                color: AppColors.primary,
                tooltip: 'Mời thành viên',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<WorkspaceMemberCubit, WorkspaceMemberState>(
        builder: (context, state) {
          if (state is WorkspaceMemberLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WorkspaceMemberError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<WorkspaceMemberCubit>().loadMembers(workspaceId),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (state is WorkspaceMemberLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: state.members.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final member = state.members[index];
                final canManage =
                    _authService.canManageWorkspace(state.currentUserRole);
                
                // Only Admin/Owner can change roles or remove members (except they can't remove themselves or owners via this UI)
                final canModifyThisMember = canManage && member.role != 'Owner';

                return _MemberCard(
                  member: member,
                  canManage: canManage,
                  onChangeRole: canModifyThisMember
                      ? () => _showChangeRoleDialog(context, member, state)
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

  // ── Invite Dialog ──────────────────────────────────────────────────────────
  void _showInviteDialog(BuildContext context) {
    final cubit = context.read<WorkspaceMemberCubit>();
    final emailCtrl = TextEditingController();
    String selectedRole = 'Member';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(
            'Mời thành viên',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: MemberRoleHelper.rolesForScope(MemberScope.workspace)
                    .where((r) => r != 'Owner')
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setDState(() => selectedRole = v ?? selectedRole),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailCtrl.text.trim();
                if (email.isEmpty) return;
                Navigator.pop(ctx);
                // Tìm user theo email, rồi mời
                final userData = await cubit.findUserByEmail(email);
                if (userData != null && context.mounted) {
                  final userId = userData['userUId'] as String? ?? '';
                  if (userId.isNotEmpty) {
                    final ok = await cubit.inviteMember(
                      workspaceId: workspaceId,
                      userId: userId,
                      role: selectedRole,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Đã mời $email thành công!'
                            : 'Không thể mời (đã tồn tại hoặc không có quyền)'),
                      ));
                    }
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy người dùng với email này.')),
                  );
                }
              },
              child: const Text('Mời'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // ── Change Role Dialog ─────────────────────────────────────────────────────
  void _showChangeRoleDialog(
      BuildContext context, WorkspaceMember member, WorkspaceMemberLoaded state) {
    String selectedRole = member.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(
            'Đổi role — ${member.userName}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: MemberRoleHelper.rolesForScope(MemberScope.workspace)
                .where((r) => r != 'Owner')
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setDState(() => selectedRole = v ?? selectedRole),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final cubit = context.read<WorkspaceMemberCubit>();
                final ok = await cubit.updateRole(
                  workspaceId: workspaceId,
                  userId: member.userUId,
                  newRole: selectedRole,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Đã cập nhật role' : 'Không thể cập nhật role'),
                  ));
                }
              },
              child: const Text('Lưu'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // ── Confirm Remove ─────────────────────────────────────────────────────────
  void _confirmRemove(BuildContext context, WorkspaceMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text('Xóa "${member.userName}" khỏi workspace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final cubit = context.read<WorkspaceMemberCubit>();
              final ok = await cubit.removeMember(
                workspaceId: workspaceId,
                userId: member.userUId,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Đã xóa thành viên' : 'Không thể xóa thành viên'),
                ));
              }
            },
            child: const Text('Xóa'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ── Member Card Widget ────────────────────────────────────────────────────────
class _MemberCard extends StatelessWidget {
  final WorkspaceMember member;
  final bool canManage;
  final VoidCallback? onChangeRole;
  final VoidCallback? onRemove;

  const _MemberCard({
    required this.member,
    required this.canManage,
    this.onChangeRole,
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
        boxShadow: AppColors.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 22,
          backgroundImage: CachedNetworkImageProvider(member.resolvedAvatarUrl),
        ),
        title: Text(
          member.userName,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          member.email,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Role chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(roleIcon, size: 11, color: roleColor),
                  const SizedBox(width: 4),
                  Text(
                    member.role,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ],
              ),
            ),
            // Actions menu
            if (canManage && (onChangeRole != null || onRemove != null))
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'role') onChangeRole?.call();
                  if (v == 'remove') onRemove?.call();
                },
                itemBuilder: (_) => [
                  if (onChangeRole != null)
                    const PopupMenuItem(
                      value: 'role',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.swap_horiz_rounded, size: 16),
                        title: Text('Đổi role'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (onRemove != null)
                    PopupMenuItem(
                      value: 'remove',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.remove_circle_outline_rounded,
                            size: 16, color: Colors.red.shade400),
                        title: Text('Xóa khỏi workspace',
                            style: TextStyle(color: Colors.red.shade400)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
                icon: const Icon(Icons.more_vert_rounded,
                    size: 18, color: AppColors.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
