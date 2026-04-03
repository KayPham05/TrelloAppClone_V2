import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class WorkspaceMenuPage extends StatefulWidget {
  const WorkspaceMenuPage({super.key});

  @override
  State<WorkspaceMenuPage> createState() => _WorkspaceMenuPageState();
}

class _WorkspaceMenuPageState extends State<WorkspaceMenuPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<_WorkspaceMember> _members = const [
    _WorkspaceMember(
      name: 'Sarah Jensen',
      role: 'Admin',
      initials: 'SJ',
      color: Color(0xFFEF4444),
    ),
    _WorkspaceMember(
      name: 'Marcus Kane',
      role: 'Member',
      initials: 'MK',
      color: Color(0xFFF59E0B),
    ),
    _WorkspaceMember(
      name: 'Lila Thorne',
      role: 'Member',
      initials: 'LT',
      color: Color(0xFF7C3AED),
    ),
  ];

  late final List<_WorkspaceBoard> _boards = [
    const _WorkspaceBoard(
      name: 'Project Alpha',
      color: Color(0xFF0C56D0),
      isStarred: true,
    ),
    const _WorkspaceBoard(
      name: 'Content Calendar',
      color: Color(0xFF006477),
      isStarred: false,
    ),
    const _WorkspaceBoard(
      name: 'Team Onboarding',
      color: Color(0xFF515F76),
      isStarred: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleStar(int index) {
    setState(() {
      final board = _boards[index];
      _boards[index] = _WorkspaceBoard(
        name: board.name,
        color: board.color,
        isStarred: !board.isStarred,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                            'Marketing Team',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.settings_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Private',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          'Free Plan',
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
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => _showSnack('Invite flow will be added later'),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Invite'),
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
              SizedBox(
                height: 32,
                width: 32,
                child: Material(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _showSnack('More actions are coming soon'),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
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
                      '12 active collaborators',
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
          ...List.generate(
            _members.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == _members.length - 1 ? 0 : 10,
              ),
              child: _buildMemberItem(_members[index]),
            ),
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
              child: const Text('View all 12 members'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(_WorkspaceMember member) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: member.color,
          child: Text(
            member.initials,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                member.role.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chat_bubble_rounded,
          size: 14,
          color: AppColors.outlineVariant,
        ),
      ],
    );
  }

  Widget _buildBoardsSection() {
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
          _boards.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildBoardItem(_boards[index], index),
          ),
        ),
        _buildCreateBoardItem(),
      ],
    );
  }

  Widget _buildBoardItem(_WorkspaceBoard board, int index) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/board-detail'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      board.color.withValues(alpha: 0.95),
                      board.color.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  board.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _toggleStar(index),
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
                icon: Icon(
                  board.isStarred
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 18,
                  color: board.isStarred
                      ? const Color(0xFFF59E0B)
                      : AppColors.outlineVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateBoardItem() {
    return CustomPaint(
      painter: _DashedRoundedRectPainter(
        color: AppColors.outlineVariant,
        radius: 12,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showSnack('Create board flow will be added later'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Create New Board',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WorkspaceMember {
  final String name;
  final String role;
  final String initials;
  final Color color;

  const _WorkspaceMember({
    required this.name,
    required this.role,
    required this.initials,
    required this.color,
  });
}

class _WorkspaceBoard {
  final String name;
  final Color color;
  final bool isStarred;

  const _WorkspaceBoard({
    required this.name,
    required this.color,
    required this.isStarred,
  });
}

class _DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRoundedRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double dashWidth = 6;
    const double dashSpace = 4;
    final Path path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
