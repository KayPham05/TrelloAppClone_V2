import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/board/presentation/pages/home_overview_page.dart';
import '../../../features/board/presentation/pages/board_list_page.dart';
import '../../../features/activity/presentation/pages/activity_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../constants/app_colors.dart';


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // 4 tabs: Home, Boards, Notifications, Account
  final List<Widget> _pages = const [
    HomeOverviewPage(),  // Tab 0 – Home (Phase 5) ✅
    BoardListPage(),     // Tab 1 – Boards (Phase 6)
    ActivityPage(),      // Tab 2 – Notifications (Phase 8)
    ProfilePage(),       // Tab 3 – Account (Phase 9)
  ];

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Trang chủ',
    ),
    _NavDestination(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Bảng',
    ),
    _NavDestination(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Thông báo',
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
                child: Icon(
                  isSelected ? destination.activeIcon : destination.icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? AppColors.navSelected   // blue-800 = #1D4ED8
                      : AppColors.navUnselected, // slate-500 = #64748B
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
