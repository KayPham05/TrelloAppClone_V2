import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../../init_dependencies.dart';
import '../../../data/datasources/board_remote_data_source.dart';
import '../../cubit/board_detail_cubit.dart';

class BoardTransferWorkspaceSheet extends StatefulWidget {
  final String currentWorkspaceId;

  /// True when the board currently lives in personal space (IsPersonal == true).
  final bool isCurrentlyPersonal;

  const BoardTransferWorkspaceSheet({
    super.key,
    required this.currentWorkspaceId,
    this.isCurrentlyPersonal = false,
  });

  @override
  State<BoardTransferWorkspaceSheet> createState() =>
      _BoardTransferWorkspaceSheetState();
}

class _BoardTransferWorkspaceSheetState
    extends State<BoardTransferWorkspaceSheet> {
  static const String _personalId = '__personal__';

  List<Map<String, dynamic>> _workspaces = [];
  bool _loading = true;
  bool _transferring = false;

  @override
  void initState() {
    super.initState();
    _loadWorkspaces();
  }

  Future<void> _loadWorkspaces() async {
    final userLocalDs = serviceLocator<UserLocalDataSource>();
    final dataSource = serviceLocator<BoardRemoteDataSource>();
    final userUId = await userLocalDs.getUserId() ?? '';
    final raw = await dataSource.getWorkspaces(userUId);
    if (mounted) {
      setState(() {
        _workspaces = raw.cast<Map<String, dynamic>>();
        _loading = false;
      });
    }
  }

  /// Returns true when this item represents the board's current location.
  bool _isCurrent(String id) {
    if (id == _personalId) return widget.isCurrentlyPersonal;
    return !widget.isCurrentlyPersonal && id == widget.currentWorkspaceId;
  }

  Future<void> _transfer(String targetId, String displayName) async {
    if (_isCurrent(targetId)) {
      Navigator.pop(context);
      return;
    }

    final isToPersonal = targetId == _personalId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận chuyển bảng'),
        content: Text(
          isToPersonal
              ? 'Chuyển bảng về Không gian cá nhân?\n\nBảng sẽ không còn thuộc nhóm làm việc nào nữa.'
              : 'Chuyển bảng sang "$displayName"?\n\nCác thành viên trong bảng sẽ được tự động thêm vào không gian làm việc mới.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
            ),
            child: const Text('Chuyển', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _transferring = true);

    // For personal space we pass empty string as workspaceId — the backend
    // should set IsPersonal = true and clear WorkspaceUId in that case.
    final transferId = isToPersonal ? '' : targetId;
    final success = await context
        .read<BoardDetailCubit>()
        .transferBoardWorkspace(transferId, displayName);

    setState(() => _transferring = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Đã chuyển bảng thành công'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Không thể chuyển bảng. Vui lòng thử lại.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildTile({
    required String id,
    required String name,
    required IconData icon,
    Color? iconColor,
  }) {
    final current = _isCurrent(id);
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: current
              ? AppColors.primaryContainer.withValues(alpha: 0.15)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? AppColors.onSurfaceVariant,
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: current ? FontWeight.w700 : FontWeight.w500,
          color: current ? AppColors.primaryContainer : AppColors.onSurface,
        ),
      ),
      trailing: current
          ? const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            )
          : null,
      onTap: _transferring ? null : () => _transfer(id, name),
    );
  }

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
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Chuyển đến không gian',
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
          if (_transferring) const LinearProgressIndicator(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      // ── Personal space item (always first) ────────────
                      _buildTile(
                        id: _personalId,
                        name: 'Không gian cá nhân',
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF7C3AED),
                      ),
                      const Divider(height: 1, indent: 16),
                      // ── Team workspaces ───────────────────────────────
                      if (_workspaces.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Không có không gian nhóm nào.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        ...List.generate(_workspaces.length, (i) {
                          final ws = _workspaces[i];
                          final id = ws['workspaceUId'] ?? ws['id'] ?? '';
                          final name = ws['name'] ?? 'Không gian làm việc';
                          return Column(
                            children: [
                              _buildTile(
                                id: id,
                                name: name,
                                icon: Icons.group_rounded,
                                iconColor: const Color(0xFF2563EB),
                              ),
                              if (i < _workspaces.length - 1)
                                const Divider(height: 1, indent: 16),
                            ],
                          );
                        }),
                    ],
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
