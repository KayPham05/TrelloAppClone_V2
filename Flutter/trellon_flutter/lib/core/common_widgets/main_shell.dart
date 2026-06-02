import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/board/presentation/pages/board_list_page.dart';
import '../../../features/inbox/presentation/pages/inbox_page.dart';
import '../../../features/planner/presentation/pages/planner_page.dart';
import '../../../features/activity/presentation/pages/activity_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/workspace/presentation/cubit/workspace_cubit.dart';
import '../../../features/activity/presentation/cubit/notification_cubit.dart';
import '../../../features/activity/presentation/cubit/notification_state.dart';
import '../../../features/activity/data/services/notification_realtime_service.dart';
import '../../../init_dependencies.dart';
import '../../../core/data_sources/user_local_data_source.dart';
import '../constants/app_colors.dart';



class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final WorkspaceCubit _workspaceCubit =
      serviceLocator<WorkspaceCubit>();
  late final NotificationCubit _notificationCubit =
      serviceLocator<NotificationCubit>();
  late final NotificationRealtimeService _notificationRealtimeService =
      serviceLocator<NotificationRealtimeService>();

  // 5 tabs: Boards, Inbox, Planner, Notifications/Activity, Account
  final List<Widget> _pages = const [
    BoardListPage(),     // Tab 0 – Boards
    InboxPage(),         // Tab 1 – Inbox
    PlannerPage(),       // Tab 2 – Planner
    ActivityPage(),      // Tab 3 – Notifications
    ProfilePage(),       // Tab 4 – Account
  ];

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Bảng',
    ),
    _NavDestination(
      icon: Icons.inbox_outlined,
      activeIcon: Icons.inbox_rounded,
      label: 'Hộp thư đến',
    ),
    _NavDestination(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Lập kế hoạch',
    ),
    _NavDestination(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Hoạt động',
    ),
    _NavDestination(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Tài khoản',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setSystemUI();
    _loadWorkspaces();
  }

  Future<void> _loadWorkspaces() async {
    // Kiểm tra token thực sự tồn tại trước khi gọi API
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final token = await secureStorage.read(key: 'access_token');
    if (token == null || token.isEmpty) {
      // Token không tồn tại → phiên đăng nhập không hợp lệ
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
      return;
    }

    final uid = await serviceLocator<UserLocalDataSource>().getUserId();
    if (uid != null && uid.isNotEmpty) {
      _workspaceCubit.loadWorkspaces();
      _notificationCubit.fetchNotifications(refresh: true);
      await _notificationRealtimeService.start();
    }
  }

  @override
  void dispose() {
    _notificationRealtimeService.stop();
    super.dispose();
  }

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.navBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WorkspaceCubit>.value(value: _workspaceCubit),
        BlocProvider<NotificationCubit>.value(value: _notificationCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _destinations.length,
              (i) => _NavItem(
                destination: _destinations[i],
                index: i,
                currentIndex: _currentIndex,
                onTap: _onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────
class _NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ── Nav item với pill indicator theo mockup ──────────────────────────────────
class _NavItem extends StatelessWidget {
  final _NavDestination destination;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.destination,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill-shaped active indicator (theo mockup: bg-blue-100 rounded-2xl)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.navSelectedBg // blue-100 = #DBEAFE
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: index == 3 // Activity tab
                    ? BlocBuilder<NotificationCubit, NotificationState>(
                        builder: (context, state) {
                          final unreadCount = context.read<NotificationCubit>().unreadCount;
                          return Badge(
                            isLabelVisible: unreadCount > 0,
                            label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                            backgroundColor: AppColors.error,
                            child: Icon(
                              isSelected ? destination.activeIcon : destination.icon,
                              key: ValueKey(isSelected),
                              color: isSelected
                                  ? AppColors.navSelected
                                  : AppColors.navUnselected,
                              size: 24,
                            ),
                          );
                        },
                      )
                    : Icon(
                        isSelected ? destination.activeIcon : destination.icon,
                        key: ValueKey(isSelected),
                        color: isSelected
                            ? AppColors.navSelected
                            : AppColors.navUnselected,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              destination.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.navSelected : AppColors.navUnselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
