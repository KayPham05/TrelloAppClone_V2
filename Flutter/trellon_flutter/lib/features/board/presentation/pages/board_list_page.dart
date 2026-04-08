import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/board_mock_data.dart';
import '../../domain/entities/workspace_entity.dart';
import '../widgets/inbox_card_widget.dart';
import '../widgets/workspace_section_widget.dart';

class BoardListPage extends StatefulWidget {
  const BoardListPage({super.key});

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  final List<WorkspaceEntity> _workspaces = BoardMockData.workspaces;
  final Set<String> _expandedWorkspaces = {'ws-1', 'ws-2'};
  final TextEditingController _searchController = TextEditingController();

  void _toggleWorkspace(String id) {
    setState(() {
      if (_expandedWorkspaces.contains(id)) {
        _expandedWorkspaces.remove(id);
      } else {
        _expandedWorkspaces.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppColors.background,
              pinned: true,
              title: const Text(
                'Bảng',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 18,
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Search Bar ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Bảng',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  // ── Inbox Quick Access ──────────────────────────────────
                  const InboxCardWidget(),

                  const SizedBox(height: 20),

                  // ── Workspace Section Header ────────────────────────────
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'KHÔNG GIAN LÀM VIỆC CỦA BẠN',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Workspaces List ─────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final workspace = _workspaces[index];
                  return WorkspaceSectionWidget(
                    workspace: workspace,
                    isExpanded: _expandedWorkspaces.contains(workspace.id),
                    onToggle: () => _toggleWorkspace(workspace.id),
                  );
                },
                childCount: _workspaces.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
