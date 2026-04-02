import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

// ── Mock Data Models ──────────────────────────────────────────────────────

enum NotificationType { mention, addedToCard, dueDate, completed, system }

class _MockNotification {
  final NotificationType type;
  final String authorName;
  final String titleHtml; // Text rich: "added you to card [Design UI]"
  final String timeText;
  final bool isUnread;
  
  // For avatar
  final String? avatarInitials;
  final Color? avatarColor;
  
  // For icon (if no avatar)
  final IconData? icon;
  final Color? iconContainerColor;
  final Color? iconColor;

  // Extra content
  final String? boardName;
  final String? quote;

  const _MockNotification({
    required this.type,
    required this.authorName,
    required this.titleHtml,
    required this.timeText,
    this.isUnread = false,
    this.avatarInitials,
    this.avatarColor,
    this.icon,
    this.iconContainerColor,
    this.iconColor,
    this.boardName,
    this.quote,
  });
}

final List<_MockNotification> _mockNotifications = [
  const _MockNotification(
    type: NotificationType.addedToCard,
    authorName: 'John Doe',
    titleHtml: 'đã thêm bạn vào thẻ Design UI',
    timeText: '2p trước',
    isUnread: true,
    avatarInitials: 'JD',
    avatarColor: Color(0xFF3B82F6), // blue
    boardName: 'Mobile App Redesign',
  ),
  const _MockNotification(
    type: NotificationType.mention,
    authorName: 'Sarah Jenkins',
    titleHtml: 'đã nhắc đến bạn trong Màn hình người dùng',
    timeText: '45p trước',
    isUnread: false,
    avatarInitials: 'SJ',
    avatarColor: Color(0xFF10B981), // green
    quote: '@alex Bạn có thể kiểm tra Prototype trước buổi họp 2h chiều mai không?',
  ),
  const _MockNotification(
    type: NotificationType.dueDate,
    authorName: '', // System alert
    titleHtml: 'Thẻ Chốt ngân sách Q3 sẽ hết hạn trong 1 giờ',
    timeText: '1 giờ trước',
    isUnread: false,
    icon: Icons.schedule_rounded,
    iconContainerColor: Color(0xFFFFEDD5), // orange-100
    iconColor: Color(0xFFEA580C), // orange-600
    boardName: 'Kế hoạch 2024',
  ),
  const _MockNotification(
    type: NotificationType.completed,
    authorName: 'Mike Chen',
    titleHtml: 'đã hoàn thành mục Cập nhật Design Tokens',
    timeText: '3 giờ trước',
    isUnread: false,
    avatarInitials: 'MC',
    avatarColor: Color(0xFF8B5CF6), // purple
  ),
  const _MockNotification(
    type: NotificationType.system,
    authorName: 'Hệ thống',
    titleHtml: 'đã tự động lưu trữ 4 thẻ không hoạt động',
    timeText: 'Hôm qua',
    isUnread: false,
    icon: Icons.rocket_launch_rounded,
    iconContainerColor: Color(0xFFF3E8FF), // purple-100
    iconColor: Color(0xFF9333EA), // purple-600
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _selectedTabIndex = 0; // 0: All, 1: Me, 2: Unread

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildNotificationList(),
                    const SizedBox(height: 80), // Padding cho bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar (Shared) ──────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFFF1F2F4),
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
              color: const Color(0xFF1E3A8A),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
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
          ),
        ],
      ),
    );
  }

  // ── Header & Tabs ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông báo',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                _buildTab('Tất cả', 0),
                _buildTab('Gửi tôi', 1),
                _buildTab('Chưa đọc', 2, hasUnreadDot: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, {bool hasUnreadDot = false}) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            boxShadow: isSelected
                ? [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
              if (hasUnreadDot) ...[
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Notification List ─────────────────────────────────────────────────────
  Widget _buildNotificationList() {
    return Column(
      children: _mockNotifications.map((notif) => _buildNotificationItem(notif)).toList(),
    );
  }

  Widget _buildNotificationItem(_MockNotification notif) {
    return Container(
      decoration: BoxDecoration(
        color: notif.isUnread ? const Color(0xFFEFF6FF) : Colors.white, // blue-50 for unread
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))), // slate-200
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar / Icon
                SizedBox(
                  width: 52,
                  child: Stack(
                    children: [
                      if (notif.avatarInitials != null)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: notif.avatarColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              notif.avatarInitials!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      else if (notif.icon != null)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: notif.iconContainerColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notif.icon, color: notif.iconColor, size: 24),
                        ),
                      
                      // Type badge (bottom right of avatar)
                      if (notif.type == NotificationType.addedToCard)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _buildBadge(Icons.person_add_rounded, AppColors.primaryContainer),
                        )
                      else if (notif.type == NotificationType.mention)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _buildBadge(Icons.chat_bubble_rounded, AppColors.secondary),
                        )
                      else if (notif.type == NotificationType.completed)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _buildBadge(Icons.check_circle_rounded, const Color(0xFF16A34A)), // green-600
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  if (notif.authorName.isNotEmpty)
                                    TextSpan(
                                      text: '${notif.authorName} ',
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.onSurface),
                                    ),
                                  TextSpan(
                                    text: notif.titleHtml,
                                    style: GoogleFonts.inter(color: AppColors.onSurface),
                                  ),
                                ],
                              ),
                              style: GoogleFonts.inter(fontSize: 14, height: 1.4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            notif.timeText,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      
                      // Quote
                      if (notif.quote != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 2)),
                          ),
                          child: Text(
                            notif.quote!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      
                      // Board chip
                      if (notif.boardName != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                notif.type == NotificationType.dueDate ? Icons.folder_rounded : Icons.dashboard_rounded,
                                size: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                notif.boardName!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Unread dot (rightmost)
                if (notif.isUnread) ...[
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, size: 10, color: Colors.white),
    );
  }
}
