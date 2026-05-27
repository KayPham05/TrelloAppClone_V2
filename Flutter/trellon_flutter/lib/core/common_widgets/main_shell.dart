import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/board/presentation/pages/home_overview_page.dart';
import '../../../features/board/presentation/pages/board_list_page.dart';
import '../../../features/inbox/presentation/pages/inbox_page.dart';
import '../../../features/planner/presentation/pages/planner_page.dart';
import '../../../features/activity/presentation/pages/activity_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/workspace/presentation/cubit/workspace_cubit.dart';
import '../../../init_dependencies.dart';
import '../../../core/data_sources/user_local_data_source.dart';
import '../constants/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final WorkspaceCubit _workspaceCubit = serviceLocator<WorkspaceCubit>();

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
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
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
    final uid = await serviceLocator<UserLocalDataSource>().getUserId();
    if (uid != null && uid.isNotEmpty) {
      _workspaceCubit.loadWorkspaces();
    }
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
    return BlocProvider<WorkspaceCubit>.value(
      value: _workspaceCubit,
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
      decoration: const BoxDecoration(
        color: AppColors.navBackground,
        border: Border(
           top: BorderSide(color: AppColors.outline, width: 0.5),
        )
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 49, // iOS standard tab bar height before safe area
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

// ── iOS styled Nav Item ──────────────────────────────────────────────────────
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
    final color = isSelected ? AppColors.navSelected : AppColors.navUnselected;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? destination.activeIcon : destination.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
