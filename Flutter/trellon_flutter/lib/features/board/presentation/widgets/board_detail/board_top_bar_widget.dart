import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../init_dependencies.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../search/presentation/delegates/global_search_delegate.dart';

class BoardTopBarWidget extends StatelessWidget {
  const BoardTopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1D4ED8),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Icon(
            Icons.grid_view_rounded,
            color: Color(0xFF1D4ED8),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            'Không gian làm việc',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () async {
              final uid = await serviceLocator<UserLocalDataSource>().getUserId();
              if (!context.mounted) return;
              debugPrint('Search tapped in BoardTopBar. UID: $uid');
              if (uid != null) {
                showSearch(context: context, delegate: GlobalSearchDelegate(userUId: uid));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Không tìm thấy User ID!')));
              }
            },
          ),
          Container(
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
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
