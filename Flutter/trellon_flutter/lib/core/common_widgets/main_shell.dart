import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/board/presentation/pages/board_list_page.dart';
import '../../../features/inbox/presentation/pages/inbox_page.dart';
import '../../../features/planner/presentation/pages/planner_page.dart';
import '../../../features/activity/presentation/pages/activity_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BoardListPage(),
    InboxPage(),
    PlannerPage(),
    ActivityPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBackground,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Bảng', index: 0, currentIndex: _currentIndex, onTap: _onTap),
              _NavItem(icon: Icons.inbox_outlined, activeIcon: Icons.inbox, label: 'Hộp thư đến', index: 1, currentIndex: _currentIndex, onTap: _onTap),
              _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Kế hoạch', index: 2, currentIndex: _currentIndex, onTap: _onTap),
              _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Hoạt động', index: 3, currentIndex: _currentIndex, onTap: _onTap),
              _NavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Tài khoản', index: 4, currentIndex: _currentIndex, onTap: _onTap),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == currentIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.navSelected : AppColors.navUnselected,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.navSelected : AppColors.navUnselected,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
