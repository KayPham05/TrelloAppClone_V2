import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/data_sources/user_local_data_source.dart';
import '../../../../init_dependencies.dart';
import '../../../board/data/datasources/board_remote_data_source.dart';
import '../../../workspace/domain/usecases/get_workspaces_usecase.dart';
import '../../data/services/notification_navigation_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../controllers/notification_tab_coordinator.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ActivityPageView();
  }
}

class ActivityPageView extends StatefulWidget {
  const ActivityPageView({super.key});

  @override
  State<ActivityPageView> createState() => _ActivityPageViewState();
}

class _ActivityPageViewState extends State<ActivityPageView> {
  int _selectedTabIndex = 0; // 0: All, 1: Me, 2: Read
  final NotificationTabCoordinator _tabCoordinator = NotificationTabCoordinator();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  final action = _tabCoordinator.onPageChanged(index);
                  setState(() => _selectedTabIndex = index);
                  if (action.fetchNotifications) {
                    context.read<NotificationCubit>().fetchNotifications(
                      refresh: true,
                      tab: action.tab,
                    );
                  }
                },
                children: const [
                  NotificationListTab(tabIndex: 0),
                  NotificationListTab(tabIndex: 1),
                  NotificationListTab(tabIndex: 2),
                ],
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
            'Không gian làm việc',
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
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  final unreadCount = context.read<NotificationCubit>().unreadCount;
                  return IgnorePointer(
                    ignoring: unreadCount == 0,
                    child: AnimatedOpacity(
                      opacity: unreadCount == 0 ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: () async {
                          final success = await context.read<NotificationCubit>().markAllAsRead();
                          if (!context.mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã đánh dấu tất cả đã đọc')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xảy ra lỗi, không thể đánh dấu')),
                            );
                          }
                        },
                        child: Text(
                          'Đánh dấu đã đọc',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
                _buildTab('Đã đọc', 2),
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
        onTap: () {
          final action = _tabCoordinator.onTap(index);
          if (!action.animateToPage) return;
          setState(() => _selectedTabIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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

}

class NotificationListTab extends StatefulWidget {
  final int tabIndex;

  const NotificationListTab({super.key, required this.tabIndex});

  @override
  State<NotificationListTab> createState() => _NotificationListTabState();
}

class _NotificationListTabState extends State<NotificationListTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().fetchNotifications(tab: _tabForIndex(widget.tabIndex));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<NotificationCubit>().fetchNotifications(
      refresh: true,
      tab: _tabForIndex(widget.tabIndex),
    );
  }

  NotificationTab _tabForIndex(int index) {
    return switch (index) {
      1 => NotificationTab.sentToMe,
      2 => NotificationTab.read,
      _ => NotificationTab.all,
    };
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
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        key: PageStorageKey('tab_${widget.tabIndex}'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationInitial || state is NotificationLoading) {
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
                final tab = _tabForIndex(widget.tabIndex);
                if (state.tab != tab) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notifications = state.notifications.toList();

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
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationEntity notif) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        final cubit = context.read<NotificationCubit>();
        final result = cubit.removeNotificationLocally(notif.id);
        if (result == null) return false;
        final entity = result.$1;
        final index = result.$2;

        var undone = false;
        final messenger = ScaffoldMessenger.of(context);
        final availableSnackBarWidth = MediaQuery.sizeOf(context).width - 32;
        final snackBarWidth = availableSnackBarWidth < 320 ? availableSnackBarWidth : 320.0;
        messenger.hideCurrentSnackBar();
        messenger
            .showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                width: snackBarWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                content: Row(
                  children: [
                    const Expanded(child: Text('Đã xóa thông báo')),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        undone = true;
                        cubit.undoDeleteNotification(entity, index);
                        messenger.hideCurrentSnackBar();
                      },
                      child: const Text('Hoàn tác'),
                    ),
                  ],
                ),
              ),
            )
            .closed
            .then((_) async {
              if (undone) return;
              final success = await cubit.confirmDeleteNotification(notif.id, entity, index);
              if (!success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa thông báo thất bại. Đã khôi phục.')),
                );
              }
            });

        return true;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: !notif.isRead ? const Color(0xFFEFF6FF) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _handleNotificationTap(context, notif);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _notificationTileContent(notif: notif),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(BuildContext context, NotificationEntity notif) async {
    if (!notif.isRead) {
      await context.read<NotificationCubit>().markAsRead(notif.id);
    }
    if (!context.mounted) return;

    // Thông báo loại "bị xóa" → hiển thị dialog, không navigate
    if (notif.type == NotificationTypeEnum.boardMemberRemoved ||
        notif.type == NotificationTypeEnum.workspaceMemberRemoved) {
      _showRemovalDialog(context, notif);
      return;
    }

    final target = await _notificationNavigationService().resolve(notif);
    if (!context.mounted) return;

    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở nội dung thông báo')),
      );
      return;
    }

    await Navigator.pushNamed(context, target.routeName, arguments: target.arguments);
  }

  void _showRemovalDialog(BuildContext context, NotificationEntity notif) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bell icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EAFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined, size: 32, color: Color(0xFF1D3A8A)),
              ),
              const SizedBox(height: 16),
              Text(
                'Thông báo hệ thống',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              Text(
                notif.message.isNotEmpty ? notif.message : notif.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Đồng ý', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Đóng', style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15, color: const Color(0xFF1E293B))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  NotificationNavigationService _notificationNavigationService() {
    return NotificationNavigationService(
      loadCardsByBoard: (boardId) async {
        final cards = await serviceLocator<BoardRemoteDataSource>().getCardsByBoard(boardId);
        return cards.map((card) => card.toEntity()).toList();
      },
      loadWorkspaces: () async {
        final userId = await serviceLocator<UserLocalDataSource>().getUserId();
        if (userId == null || userId.isEmpty) return [];
        return serviceLocator<GetWorkspacesUseCase>().call(userId);
      },
    );
  }

  Widget _notificationTileContent({required NotificationEntity notif}) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notif.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: !notif.isRead ? FontWeight.w700 : FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6, left: 8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _formatTime(notif.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          if (notif.actorName != null && notif.actorName!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFFCBD5E1),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notif.actorName!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationIcon(NotificationTypeEnum type) {
    final (icon, color, background) = switch (type) {
      NotificationTypeEnum.assign => (
          Icons.person_add_rounded,
          AppColors.primaryContainer,
          const Color(0xFFEFF6FF),
        ),
      NotificationTypeEnum.mention => (
          Icons.chat_bubble_rounded,
          AppColors.secondary,
          const Color(0xFFF1F5F9),
        ),
      NotificationTypeEnum.due || NotificationTypeEnum.dueDateChanged || NotificationTypeEnum.dueDateReminder => (
          Icons.schedule_rounded,
          const Color(0xFFEA580C),
          const Color(0xFFFFEDD5),
        ),
      _ => (
          Icons.notifications_rounded,
          AppColors.primary,
          const Color(0xFFEFF6FF),
        ),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
