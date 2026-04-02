import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

// ── Mock data ──────────────────────────────────────────────────────────────
class _MockBoard {
  final String title;
  final Color color;
  final bool isStarred;
  const _MockBoard({
    required this.title,
    required this.color,
    this.isStarred = false,
  });
}

final List<_MockBoard> _mockBoards = [
  _MockBoard(title: 'Product Roadmap 2024',   color: Color(0xFF0C56D0), isStarred: true),
  _MockBoard(title: 'Team Spirit & Culture',   color: Color(0xFF16A34A), isStarred: true),
  _MockBoard(title: 'Mobile App Design',       color: Color(0xFF7C3AED), isStarred: false),
  _MockBoard(title: 'Backlog & Maintenance',   color: Color(0xFF0F766E), isStarred: false),
  _MockBoard(title: 'Marketing Q4 2024',       color: Color(0xFFB45309), isStarred: false),
];

// ── Page ───────────────────────────────────────────────────────────────────
class HomeOverviewPage extends StatefulWidget {
  const HomeOverviewPage({super.key});

  @override
  State<HomeOverviewPage> createState() => _HomeOverviewPageState();
}

class _HomeOverviewPageState extends State<HomeOverviewPage> {
  late List<_MockBoard> _boards;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _boards = List.from(_mockBoards);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_MockBoard> get _starredBoards =>
      _boards.where((b) => b.isStarred).toList();

  List<_MockBoard> get _filteredBoards {
    if (_searchQuery.isEmpty) return _boards;
    return _boards
        .where((b) => b.title.toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _toggleStar(int index) {
    setState(() => _boards[index] = _MockBoard(
          title: _boards[index].title,
          color: _boards[index].color,
          isStarred: !_boards[index].isStarred,
        ));
  }

  void _showCreateBoardDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tạo bảng mới (chưa tích hợp backend)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (_starredBoards.isNotEmpty && _searchQuery.isEmpty) ...[
                          _buildSectionHeader(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Bảng yêu thích',
                          ),
                          const SizedBox(height: 12),
                          _buildBoardGrid(_starredBoards, isStarred: true),
                          const SizedBox(height: 28),
                        ],
                        _buildSectionHeader(
                          icon: Icons.person_outline_rounded,
                          iconColor: AppColors.onSurfaceVariant,
                          title: 'Bảng của bạn',
                        ),
                        const SizedBox(height: 12),
                        _buildBoardGrid(_filteredBoards, isStarred: false),
                        if (_filteredBoards.isEmpty)
                          _buildEmptySearch(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFFF1F2F4), // slate-100
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.grid_view_rounded, color: Color(0xFF1D4ED8), size: 24),
          const SizedBox(width: 10),
          Text(
            'Workspace',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A), // blue-900
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Search bar (desktop – hidden on mobile)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: _buildCompactSearch(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSearch() {
    return SizedBox(
      width: 200,
      height: 36,
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bảng',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 18),
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          isDense: true,
        ),
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ── Board grid ───────────────────────────────────────────────────────────
  Widget _buildBoardGrid(List<_MockBoard> boards, {required bool isStarred}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: boards.length + (isStarred ? 0 : 1), // +1 for "create" card
      itemBuilder: (context, index) {
        if (!isStarred && index == boards.length) {
          return _buildCreateCard();
        }
        final board = boards[index];
        final globalIndex = _boards.indexOf(board);
        return _buildBoardCard(board, globalIndex);
      },
    );
  }

  Widget _buildBoardCard(_MockBoard board, int globalIndex) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/board-detail'),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: board.color),
                    // Subtle pattern overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        board.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (globalIndex >= 0) _toggleStar(globalIndex);
                      },
                      child: Icon(
                        board.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: board.isStarred
                            ? const Color(0xFFF59E0B) // amber-500
                            : AppColors.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateCard() {
    return GestureDetector(
      onTap: _showCreateBoardDialog,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Tạo bảng mới',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'Không tìm thấy bảng nào',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _showCreateBoardDialog,
      backgroundColor: AppColors.primaryContainer,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 30),
    );
  }
}
