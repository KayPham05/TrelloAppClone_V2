import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/workspace_entity.dart';
import '../../../../core/widgets/cover_picker_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/workspace_cubit.dart';
import '../../../../init_dependencies.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../widgets/dashed_create_board_card.dart';
import '../widgets/workspace_board_item_widget.dart';
import '../widgets/create_workspace_dialog.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/create_board_dialog.dart';

class WorkspaceMenuPage extends StatefulWidget {
  final WorkspaceEntity workspace;
  const WorkspaceMenuPage({super.key, required this.workspace});

  @override
  State<WorkspaceMenuPage> createState() => _WorkspaceMenuPageState();
}

class _WorkspaceMenuPageState extends State<WorkspaceMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  late WorkspaceEntity _currentWorkspace;

  @override
  void initState() {
    super.initState();
    _currentWorkspace = widget.workspace;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditWorkspace() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateWorkspaceDialog(workspace: _currentWorkspace),
    );

    if (result != null && mounted) {
      context.read<WorkspaceCubit>().updateWorkspace(
        _currentWorkspace.id,
        result['name'],
        result['description'],
        result['type'],
      );
      // Update local state temporarily if needed or wait for rebuild
      setState(() {
        _currentWorkspace = _currentWorkspace.copyWith(
          name: result['name'],
          description: result['description'],
          type: result['type'],
        );
      });
    }
  }

  void _showDeleteWorkspace() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa không gian'),
        content: Text('Bạn có chắc chắn muốn xóa "${_currentWorkspace.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<WorkspaceCubit>().deleteWorkspace(_currentWorkspace.id);
      Navigator.pop(context);
    }
  }

  void _showAddMember() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );

    if (email != null && mounted) {
      context.read<WorkspaceCubit>().addMember(_currentWorkspace.id, email);
      _showSnack('Đã gửi lời mời tới $email');
    }
  }

  void _showCreateBoard() async {
    final boardName = await showDialog<String>(
      context: context,
      builder: (context) => const CreateBoardDialog(),
    );

    if (boardName != null && mounted) {
      context.read<WorkspaceCubit>().createBoard(_currentWorkspace.id, boardName, null);
    }
  }

  void _toggleStar(int index) {
    // Logic for starring/unstarring a board can be implemented here later
    // For now, satisfy the widget callback requirement
    _showSnack('Tính năng đánh dấu bảng sẽ sớm được cập nhật');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkspaceCubit, WorkspaceState>(
      listener: (context, state) {
        if (state is WorkspaceError) {
          _showSnack(state.message);
        }
        if (state is WorkspaceLoaded) {
          // Update _currentWorkspace to the one currently being viewed
          final updated = [...state.personal, ...state.team]
              .where((w) => w.id == _currentWorkspace.id)
              .firstOrNull;
          if (updated != null) {
            setState(() {
              _currentWorkspace = updated;
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(context),
                const Divider(height: 1, color: Color(0xFFDBEAFE)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWorkspaceHeader(),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildMembersCard(),
                        const SizedBox(height: 16),
                        _buildBoardsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.primary,
          ),
          Text(
            'Workspace Menu',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_work_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentWorkspace.name,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            _currentWorkspace.type == WorkspaceType.personal ? Icons.person_rounded : Icons.group_rounded,
                            size: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currentWorkspace.type == WorkspaceType.personal ? 'Cá nhân' : 'Nhóm',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: _showAddMember,
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Mời'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showEditWorkspace,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  color: AppColors.onSurfaceVariant,
                  tooltip: 'Sửa',
                ),
                IconButton(
                  onPressed: _showDeleteWorkspace,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: Colors.redAccent,
                  tooltip: 'Xóa',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Search boards...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.outline,
          size: 20,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryContainer,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildMembersCard() {
    // Removed mock member list and replaced with empty representation
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Members',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '0 active collaborators',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.group_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  _showSnack('Members list page will be added later'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: AppColors.onSurface,
                elevation: 0,
                textStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View all members'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardsSection() {
    final boards = widget.workspace.boards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your Boards',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  _showSnack('Boards list page will be added later'),
              child: Text(
                'View all',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(
          _currentWorkspace.boards.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: WorkspaceBoardItemWidget(
              board: _currentWorkspace.boards[index], 
              onToggleStar: () => _toggleStar(index),
            ),
          ),
        ),
        DashedCreateBoardCard(
          onTap: _showCreateBoard,
        ),
      ],
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
