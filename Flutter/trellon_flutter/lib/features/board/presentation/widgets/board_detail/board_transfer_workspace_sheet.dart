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

  const BoardTransferWorkspaceSheet({super.key, required this.currentWorkspaceId});

  @override
  State<BoardTransferWorkspaceSheet> createState() => _BoardTransferWorkspaceSheetState();
}

class _BoardTransferWorkspaceSheetState extends State<BoardTransferWorkspaceSheet> {
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

  Future<void> _transfer(String workspaceId, String workspaceName) async {
    if (workspaceId == widget.currentWorkspaceId) {
      Navigator.pop(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận chuyển bảng'),
        content: Text(
          'Chuyển bảng sang "$workspaceName"?\n\nCác thành viên trong bảng sẽ được tự động thêm vào không gian làm việc mới.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
            child: const Text('Chuyển', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _transferring = true);
    final success = await context
        .read<BoardDetailCubit>()
        .transferBoardWorkspace(workspaceId, workspaceName);
    setState(() => _transferring = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã chuyển bảng thành công'), behavior: SnackBarBehavior.floating),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Không thể chuyển bảng. Vui lòng thử lại.'), behavior: SnackBarBehavior.floating),
        );
      }
    }
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
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: Text('Không gian làm việc', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_transferring)
            const LinearProgressIndicator(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _workspaces.isEmpty
                    ? Center(
                        child: Text(
                          'Không có không gian làm việc nào.',
                          style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                        itemCount: _workspaces.length,
                        itemBuilder: (_, i) {
                          final ws = _workspaces[i];
                          final id = ws['workspaceUId'] ?? ws['id'] ?? '';
                          final name = ws['name'] ?? 'Workspace';
                          final isCurrent = id == widget.currentWorkspaceId;
                          return ListTile(
                            title: Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                            trailing: isCurrent
                                ? const Icon(Icons.check_rounded, color: Color(0xFF2563EB))
                                : null,
                            onTap: _transferring ? null : () => _transfer(id, name),
                          );
                        },
                      ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
