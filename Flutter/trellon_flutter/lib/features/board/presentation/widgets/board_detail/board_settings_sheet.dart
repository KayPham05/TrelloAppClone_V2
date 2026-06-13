import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/board_detail_cubit.dart';
import '../../cubit/board_detail_state.dart';
import 'board_background_sheet.dart';
import 'board_transfer_workspace_sheet.dart';
import 'board_archive_sheet.dart';
import 'board_visibility_sheet.dart';

class BoardSettingsSheet extends StatefulWidget {
  const BoardSettingsSheet({super.key});

  @override
  State<BoardSettingsSheet> createState() => _BoardSettingsSheetState();
}

class _BoardSettingsSheetState extends State<BoardSettingsSheet> {
  late TextEditingController _nameController;
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<BoardDetailCubit>().state;
    final name = s is BoardDetailLoaded ? s.boardName : '';
    _nameController = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _canEdit(BoardDetailLoaded state) {
    final role = state.boardRole?.toLowerCase() ?? '';
    return role == 'admin' || role == 'owner';
  }

  bool _isOwner(BoardDetailLoaded state) =>
      state.boardRole?.toLowerCase() == 'owner';

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 Tính năng đang phát triển'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openBackground(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<BoardDetailCubit>(),
        child: const BoardBackgroundSheet(),
      ),
    );
  }

  void _openTransferWorkspace(BuildContext ctx, BoardDetailLoaded state) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<BoardDetailCubit>(),
        child: BoardTransferWorkspaceSheet(
          currentWorkspaceId: state.workspaceId ?? '',
          isCurrentlyPersonal:
              (state.workspaceId == null || state.workspaceId!.isEmpty),
        ),
      ),
    );
  }

  void _openArchive(BuildContext ctx, BoardDetailLoaded state) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<BoardDetailCubit>(),
        child: BoardArchiveSheet(boardId: state.boardId),
      ),
    );
  }

  void _openVisibility(BuildContext ctx, BoardDetailLoaded state) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<BoardDetailCubit>(),
        child: BoardVisibilitySheet(
          currentVisibility: state.boardVisibility ?? 'Private',
        ),
      ),
    );
  }

  void _confirmDeleteBoard(BuildContext ctx, BoardDetailLoaded state) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xóa bảng'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa bảng này không? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pop(ctx);
              ctx.read<BoardDetailCubit>().deleteBoard(state.boardId);
              Navigator.pop(ctx); // Use ctx to pop the board detail page
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _visibilityLabel(String? v) {
    switch (v) {
      case 'Public':
        return 'Công khai';
      case 'Workspace':
        return 'Không gian làm việc';
      default:
        return 'Thành viên';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardDetailCubit, BoardDetailState>(
      builder: (ctx, state) {
        if (state is! BoardDetailLoaded) return const SizedBox.shrink();
        final canEdit = _canEdit(state);
        final isOwner = _isOwner(state);

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
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              // Header
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
                        'Thiết lập bảng',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    // ── Group 1: Core settings ──────────────────────────
                    // Tên
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tên'),
                      subtitle: canEdit
                          ? _editingName
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _nameController,
                                          autofocus: true,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                            border: OutlineInputBorder(),
                                          ),
                                          onSubmitted: (v) {
                                            setState(
                                              () => _editingName = false,
                                            );
                                            if (v.trim().isNotEmpty) {
                                              ctx
                                                  .read<BoardDetailCubit>()
                                                  .updateBoardName(v.trim());
                                            }
                                          },
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() => _editingName = false);
                                          final v = _nameController.text.trim();
                                          if (v.isNotEmpty) {
                                            ctx
                                                .read<BoardDetailCubit>()
                                                .updateBoardName(v);
                                          }
                                        },
                                        child: const Text('Lưu'),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () =>
                                        setState(() => _editingName = true),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            state.boardName,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: AppColors.outlineVariant,
                                        ),
                                      ],
                                    ),
                                  )
                          : Text(
                              state.boardName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                    ),
                    const Divider(),

                    // Không gian làm việc
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Không gian làm việc'),
                      subtitle: Text(
                        state.workspaceName ?? 'Cá nhân',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: isOwner
                          ? const Icon(Icons.chevron_right, color: Colors.grey)
                          : null,
                      onTap: isOwner
                          ? () => _openTransferWorkspace(ctx, state)
                          : null,
                    ),
                    const Divider(),

                    // Phông nền
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Phông nền'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBgPreview(state.backgroundUrl),
                          if (canEdit)
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: canEdit ? () => _openBackground(ctx) : null,
                    ),
                    const Divider(),

                    // Hiển thị ảnh bìa thẻ – Coming soon toggle
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hiển thị ảnh bìa thẻ'),
                      trailing: Switch(
                        value: true,
                        onChanged: canEdit ? (_) => _showComingSoon() : null,
                        activeThumbColor: AppColors.primaryContainer,
                      ),
                    ),
                    const Divider(),

                    // Chỉnh sửa nhãn
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Chỉnh sửa nhãn'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: _showComingSoon,
                    ),
                    const Divider(),

                    // Đang theo dõi
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Đang theo dõi'),
                      trailing: Switch(
                        value: false,
                        onChanged: (_) => _showComingSoon(),
                        activeThumbColor: AppColors.primaryContainer,
                      ),
                    ),
                    const Divider(),

                    // Cài đặt thêm thẻ qua email
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cài đặt thêm thẻ qua email'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: _showComingSoon,
                    ),
                    const Divider(),

                    // ── Group 2: Lưu trữ ────────────────────────────────
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Lưu trữ'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => _openArchive(ctx, state),
                    ),
                    const Divider(),

                    // ── Group 3: Hiển thị / quyền ───────────────────────
                    // Hiển thị (visibility)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hiển thị'),
                      subtitle: Text(
                        _visibilityLabel(state.boardVisibility),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: canEdit
                          ? const Icon(Icons.chevron_right, color: Colors.grey)
                          : null,
                      onTap: canEdit ? () => _openVisibility(ctx, state) : null,
                    ),
                    const Divider(),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Quyền bình luận'),
                      subtitle: Text(
                        'Thành viên',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: _showComingSoon,
                    ),
                    const Divider(),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Bình chọn'),
                      subtitle: Text(
                        'Đã tắt',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: _showComingSoon,
                    ),
                    const Divider(),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Thêm thành viên'),
                      subtitle: Text(
                        'Thành viên',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: _showComingSoon,
                    ),

                    if (isOwner) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Xóa bảng',
                          style: GoogleFonts.inter(
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
                        ),
                        onTap: () => _confirmDeleteBoard(ctx, state),
                      ),
                    ],

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBgPreview(String? url) {
    if (url == null) {
      return Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }
    final isColor = url.startsWith('#');
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        image: !isColor
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
        color: isColor ? _parseHex(url) : null,
      ),
    );
  }

  Color _parseHex(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return AppColors.primaryContainer;
    }
  }
}
