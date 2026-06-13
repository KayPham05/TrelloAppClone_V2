import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_debounce/easy_debounce.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeAppBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const HomeAppBarWidget({super.key, required this.onSearchChanged});

  @override
  State<HomeAppBarWidget> createState() => _HomeAppBarWidgetState();
}

class _HomeAppBarWidgetState extends State<HomeAppBarWidget> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    EasyDebounce.cancel('home-overview-search');
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    EasyDebounce.debounce(
      'home-overview-search',
      const Duration(milliseconds: 300),
      () {
        if (!mounted) return;
        widget.onSearchChanged(_searchController.text.toLowerCase());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4), // slate-100
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/workspace-menu'),
            icon: const Icon(
              Icons.grid_view_rounded,
              color: Color(0xFF1D4ED8),
              size: 24,
            ),
            tooltip: 'Trình đơn không gian làm việc',
            visualDensity: VisualDensity.compact,
            splashRadius: 20,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/workspace-menu'),
            child: Text(
              'Không gian làm việc',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3A8A), // blue-900
                letterSpacing: -0.3,
              ),
            ),
          ),
          const Spacer(),
          // Search bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: SizedBox(
              width: 200,
              height: 36,
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bảng',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryContainer,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
