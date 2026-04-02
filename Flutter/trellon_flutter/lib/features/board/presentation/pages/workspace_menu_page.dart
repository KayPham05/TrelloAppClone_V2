import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class WorkspaceMenuPage extends StatelessWidget {
  const WorkspaceMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const Divider(height: 1, color: Color(0xFFDBEAFE)), // blue-100 equivalent
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWorkspaceHeader(),
                    const SizedBox(height: 40),
                    _buildSearchBar(),
                    const SizedBox(height: 40),
                    _buildMembersSection(),
                    const SizedBox(height: 40),
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

  // ── Top Bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              hoverColor: AppColors.surfaceContainer,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Menu Không gian',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.3),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildWorkspaceHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        
        final content = [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.group_work_rounded, color: AppColors.onPrimaryContainer, size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Đội Marketing',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.5),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.settings_rounded, color: AppColors.outline, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.lock_rounded, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('Riêng tư', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                        const SizedBox(width: 12),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.outlineVariant, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Text('Gói Miễn phí', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isNarrow) const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text('Mời', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                  foregroundColor: AppColors.onSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                ),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ];

        return isNarrow
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: content)
            : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: content);
      },
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bảng...',
          hintStyle: GoogleFonts.inter(color: AppColors.outlineVariant, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ── Members Section ──────────────────────────────────────────────────
  Widget _buildMembersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A191C1E), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thành viên', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                  const SizedBox(height: 2),
                  Text('12 cộng tác viên hoạt động', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                ],
              ),
              const Icon(Icons.group_rounded, color: AppColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 24),
          _buildMemberItem('Sarah Jensen', 'Quản trị', const Color(0xFF3B82F6)),
          const SizedBox(height: 16),
          _buildMemberItem('Marcus Kane', 'Thành viên', const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildMemberItem('Lila Thorne', 'Thành viên', const Color(0xFFF59E0B)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: AppColors.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Xem tất cả 12 thành viên',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(String name, String role, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(child: Text(name.substring(0, 1), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                Text(role.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
        const Icon(Icons.chat_bubble_rounded, size: 20, color: AppColors.outlineVariant),
      ],
    );
  }

  // ── Boards Section ───────────────────────────────────────────────────
  Widget _buildBoardsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bảng của bạn', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            TextButton(
              onPressed: () {},
              child: Text('Xem tất cả', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
            )
          ],
        ),
        const SizedBox(height: 12),
        _buildBoardItem('Dự án Alpha', const Color(0xFF003D9B), true),
        const SizedBox(height: 12),
        _buildBoardItem('Lịch nội dung', const Color(0xFF006477), false),
        const SizedBox(height: 12),
        _buildBoardItem('Tuyển dụng', const Color(0xFF515F76), false),
        const SizedBox(height: 12),
        _buildAddBoardItem(),
      ],
    );
  }

  Widget _buildBoardItem(String title, Color color, bool isStarred) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(width: 16),
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            ],
          ),
          Icon(Icons.star_rounded, size: 24, color: isStarred ? AppColors.primary : AppColors.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildAddBoardItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid, width: 2), // Should be dashed but keeping it solid for simplicity in Flutter
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.add_rounded, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Text('Tạo Bảng Mới', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
