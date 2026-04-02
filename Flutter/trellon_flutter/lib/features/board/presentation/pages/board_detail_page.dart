import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

// ── Mock Data Models ──────────────────────────────────────────────────────

class _MockLabel {
  final Color color;
  const _MockLabel(this.color);
}

class _MockCard {
  final String title;
  final List<_MockLabel> labels;
  final List<String> avatarInitials;
  final String? dueDate;
  final bool isOverdue;
  final int? commentCount;
  final int? attachmentCount;
  final bool? hasNotes;
  final bool isHighlighted;
  final Color? highlightColor;

  const _MockCard({
    required this.title,
    this.labels = const [],
    this.avatarInitials = const [],
    this.dueDate,
    this.isOverdue = false,
    this.commentCount,
    this.attachmentCount,
    this.hasNotes = false,
    this.isHighlighted = false,
    this.highlightColor,
  });
}

class _MockList {
  final String title;
  final List<_MockCard> cards;
  const _MockList({required this.title, required this.cards});
}

final _mockBoardData = [
  _MockList(title: 'Cần làm', cards: [
    _MockCard(
      title: 'Tài liệu thiết kế hệ thống giao diện',
      labels: [_MockLabel(Color(0xFF3B82F6)), _MockLabel(Color(0xFF10B981))],
      avatarInitials: ['A'],
      hasNotes: true,
      commentCount: 3,
    ),
    _MockCard(
      title: 'Xem lại mockup trang landing hi-fi',
      avatarInitials: ['B', 'C'],
      dueDate: '12/10',
      isOverdue: true,
    ),
    _MockCard(
      title: 'Lập kế hoạch ngân sách Q4',
      attachmentCount: 1,
    ),
    _MockCard(
      title: 'Xem lại chiến lược mạng xã hội',
      labels: [_MockLabel(Color(0xFFF59E0B))],
    ),
  ]),
  _MockList(title: 'Đang làm', cards: [
    _MockCard(
      title: 'Tích hợp API cổng thanh toán',
      isHighlighted: true,
      highlightColor: Color(0xFF2563EB),
      avatarInitials: ['D', 'E'],
      dueDate: '15/10',
    ),
    _MockCard(
      title: 'Thiết kế onboarding người dùng',
      labels: [_MockLabel(Color(0xFF8B5CF6))],
      avatarInitials: ['F'],
      commentCount: 6,
    ),
    _MockCard(
      title: 'Viết unit test cho auth module',
      avatarInitials: ['A'],
      hasNotes: true,
    ),
    _MockCard(
      title: 'Cập nhật chính sách bảo mật',
    ),
  ]),
  _MockList(title: 'Hoàn thành', cards: [
    _MockCard(
      title: 'Thiết lập CI/CD pipeline',
      avatarInitials: ['B'],
      labels: [_MockLabel(Color(0xFF059669))],
    ),
    _MockCard(
      title: 'Tái cấu trúc lớp service backend',
      avatarInitials: ['G'],
      commentCount: 4,
    ),
    _MockCard(
      title: 'Phỏng vấn người dùng về UX',
      labels: [_MockLabel(Color(0xFFEC4899)), _MockLabel(Color(0xFF6366F1))],
      avatarInitials: ['A', 'H'],
    ),
  ]),
];

// ── Page ──────────────────────────────────────────────────────────────────

class BoardDetailPage extends StatefulWidget {
  const BoardDetailPage({super.key});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  bool _isStarred = false;
  final String _boardName = 'Phát triển sản phẩm 2024';
  final Color _boardColor = AppColors.primaryContainer; // #0052CC

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _boardColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            _buildBoardSubBar(),
            Expanded(child: _buildKanbanColumns()),
          ],
        ),
      ),
    );
  }

  // ── Top Bar (shared with home) ──────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1D4ED8)),
            onPressed: () => Navigator.pop(context),
          ),
          const Icon(Icons.grid_view_rounded, color: Color(0xFF1D4ED8), size: 22),
          const SizedBox(width: 8),
          Text(
            'Workspace',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          _buildAvatarChip(),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildAvatarChip() {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(right: 4),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'JS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Board Sub-bar ────────────────────────────────────────────────────────
  Widget _buildBoardSubBar() {
    return Container(
      color: _boardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _boardName,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Vertical divider
          Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(width: 8),
          // Favourite button
          GestureDetector(
            onTap: () => setState(() => _isStarred = !_isStarred),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Yêu thích',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter
          _boardIconButton(Icons.filter_list_rounded),
          const SizedBox(width: 4),
          // More
          _boardIconButton(Icons.more_horiz_rounded),
        ],
      ),
    );
  }

  Widget _boardIconButton(IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Kanban Columns ────────────────────────────────────────────────────────
  Widget _buildKanbanColumns() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _mockBoardData.length + 1,
      itemBuilder: (context, index) {
        if (index == _mockBoardData.length) {
          return _buildAddListButton();
        }
        return _buildColumn(_mockBoardData[index]);
      },
    );
  }

  Widget _buildColumn(_MockList list) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Column header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    list.title.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${list.cards.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards in scrollable area
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  ...list.cards.map((card) => _buildCard(card)),
                ],
              ),
            ),
          ),

          // "Add a card" at bottom
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm thẻ mới (chưa tích hợp backend)')),
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, size: 18, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Thêm thẻ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_MockCard card) {
    return GestureDetector(
      onTap: () {
        // Phase 7: Navigate to CardDetailPage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chi tiết thẻ (Phase 7)')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: card.isHighlighted
              ? Border(left: BorderSide(color: card.highlightColor!, width: 3))
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F191C1E),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Labels
              if (card.labels.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  children: card.labels
                      .map((l) => Container(
                            width: 28,
                            height: 6,
                            decoration: BoxDecoration(
                              color: l.color,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Highlighted label
              if (card.isHighlighted && card.highlightColor != null) ...[
                Text(
                  'Đang xử lý',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: card.highlightColor,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Title
              Text(
                card.title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                  height: 1.35,
                ),
              ),

              // Meta row (due date, icons, avatars)
              if (card.dueDate != null ||
                  card.commentCount != null ||
                  card.attachmentCount != null ||
                  (card.hasNotes ?? false) ||
                  card.avatarInitials.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      // Due date chip
                      if (card.dueDate != null) ...[
                        _buildDueDateChip(card.dueDate!, card.isOverdue),
                        const SizedBox(width: 6),
                      ],
                      // Notes icon
                      if (card.hasNotes ?? false) ...[
                        const Icon(Icons.notes_rounded, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                      ],
                      // Comments
                      if (card.commentCount != null) ...[
                        const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(
                          '${card.commentCount}',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Attachments
                      if (card.attachmentCount != null) ...[
                        const Icon(Icons.attach_file_rounded, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(
                          '${card.attachmentCount}',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                      const Spacer(),
                      // Avatar stack
                      if (card.avatarInitials.isNotEmpty)
                        _buildAvatarStack(card.avatarInitials),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDueDateChip(String date, bool isOverdue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isOverdue
            ? const Color(0xFFFEF2F2) // red-50
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 11,
            color: isOverdue ? const Color(0xFFDC2626) : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isOverdue ? const Color(0xFFDC2626) : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(List<String> initials) {
    const double size = 22;
    const double overlap = 8;
    final double width = size + (initials.length - 1) * (size - overlap);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: List.generate(initials.length, (i) {
          return Positioned(
            left: i * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _avatarColor(initials[i]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  initials[i],
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _avatarColor(String initial) {
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF06B6D4),
      Color(0xFFEF4444),
      Color(0xFF6366F1),
    ];
    return colors[initial.codeUnitAt(0) % colors.length];
  }

  // ── "Add another list" button ─────────────────────────────────────────
  Widget _buildAddListButton() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm cột mới (chưa tích hợp backend)')),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              'Thêm cột mới',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
