import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/notification_entity.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<NotificationCubit>()..fetchNotifications(refresh: true),
      child: const ActivityPageView(),
    );
  }
}

class ActivityPageView extends StatefulWidget {
  const ActivityPageView({super.key});

  @override
  State<ActivityPageView> createState() => _ActivityPageViewState();
}

class _ActivityPageViewState extends State<ActivityPageView> {
  int _selectedTabIndex = 0; // 0: All, 1: Me, 2: Unread
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().fetchNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<NotificationCubit>().fetchNotifications(refresh: true);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
    }
  }

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
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),
                    _buildNotificationList(),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông báo',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<NotificationCubit>().markAllAsRead();
                },
                child: Text(
                  'Đánh dấu đã đọc',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                _buildTab('Chưa đọc', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
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
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Notification List ─────────────────────────────────────────────────────
  Widget _buildNotificationList() {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationInitial || (state is NotificationLoading && context.read<NotificationCubit>().state is! NotificationLoaded)) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is NotificationError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(state.message, style: GoogleFonts.inter(color: Colors.red)),
                  TextButton(
                    onPressed: _onRefresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is NotificationLoaded) {
          List<NotificationEntity> notifications = state.notifications;
          
          if (_selectedTabIndex == 1) { // Gửi tôi
            notifications = notifications.where((n) => n.type == NotificationTypeEnum.assign || n.type == NotificationTypeEnum.mention).toList();
          } else if (_selectedTabIndex == 2) { // Chưa đọc
            notifications = notifications.where((n) => !n.isRead).toList();
          }

          if (notifications.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Text('Không có thông báo nào', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == notifications.length) {
                  return state.hasReachedMax
                      ? const SizedBox.shrink()
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                }
                return _buildNotificationItem(notifications[index]);
              },
              childCount: notifications.length + (state.hasReachedMax ? 0 : 1),
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildNotificationItem(NotificationEntity notif) {
    IconData iconData;
    Color iconColor;
    Color iconContainerColor;

    switch (notif.type) {
      case NotificationTypeEnum.assign:
        iconData = Icons.person_add_rounded;
        iconColor = AppColors.primaryContainer;
        iconContainerColor = const Color(0xFFEFF6FF);
        break;
      case NotificationTypeEnum.mention:
        iconData = Icons.chat_bubble_rounded;
        iconColor = AppColors.secondary;
        iconContainerColor = const Color(0xFFF1F5F9);
        break;
      case NotificationTypeEnum.due:
        iconData = Icons.schedule_rounded;
        iconColor = const Color(0xFFEA580C);
        iconContainerColor = const Color(0xFFFFEDD5);
        break;
      default:
        iconData = Icons.notifications_rounded;
        iconColor = AppColors.primary;
        iconContainerColor = const Color(0xFFEFF6FF);
    }

    final avatarInitials = notif.actorName != null && notif.actorName!.isNotEmpty
        ? notif.actorName!.substring(0, 1).toUpperCase()
        : 'U';

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationCubit>().deleteNotification(notif.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: !notif.isRead ? const Color(0xFFEFF6FF) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!notif.isRead) {
                context.read<NotificationCubit>().markAsRead(notif.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 52,
                    child: Stack(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconContainerColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              avatarInitials,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _buildBadge(iconData, iconColor),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
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
                                    if (notif.actorName != null && notif.actorName!.isNotEmpty)
                                      TextSpan(
                                        text: '${notif.actorName} ',
                                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.onSurface),
                                      ),
                                    TextSpan(
                                      text: notif.title,
                                      style: GoogleFonts.inter(color: AppColors.onSurface),
                                    ),
                                  ],
                                ),
                                style: GoogleFonts.inter(fontSize: 14, height: 1.4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatTime(notif.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (notif.message.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                            decoration: const BoxDecoration(
                              border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 2)),
                            ),
                            child: Text(
                              notif.message,
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
                        if (notif.boardId != null) ...[
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
                                const Icon(Icons.dashboard_rounded, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(
                                  'Board',
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
                  if (!notif.isRead) ...[
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
