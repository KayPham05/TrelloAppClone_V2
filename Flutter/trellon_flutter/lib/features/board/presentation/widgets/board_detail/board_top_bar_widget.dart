import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../../init_dependencies.dart';
import '../../../../search/presentation/delegates/global_search_delegate.dart';
import '../../cubit/board_detail_cubit.dart';
import '../../cubit/board_detail_state.dart';

class BoardTopBarWidget extends StatelessWidget {
  const BoardTopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardDetailCubit, BoardDetailState>(
      builder: (context, state) {
        String title = 'Bảng';
        if (state is BoardDetailLoaded) {
          title = state.workspaceName ?? (state.isPersonal ? 'Bảng cá nhân' : 'Không gian làm việc');
        }

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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                onPressed: () async {
                  final uid = await serviceLocator<UserLocalDataSource>().getUserId();
                  if (!context.mounted) return;
                  if (uid != null) {
                    showSearch(context: context, delegate: GlobalSearchDelegate(userUId: uid));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Không tìm thấy User ID!')));
                  }
                },
              ),
              _buildUserAvatar(),
              const SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar() {
    return FutureBuilder<String?>(
      future: serviceLocator<UserLocalDataSource>().getUserName(),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'U';
        final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
        
        return Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.only(right: 4),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
