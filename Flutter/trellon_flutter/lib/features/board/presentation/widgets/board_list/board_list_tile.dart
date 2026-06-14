import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/color_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../init_dependencies.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../cubit/board_cubit.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/board_entity.dart';

class BoardListTile extends StatelessWidget {
  final BoardEntity board;
  const BoardListTile({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(board.coverColor ?? '#0079BF');
    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(context, '/board-detail', arguments: {
          'boardId': board.id,
          'boardName': board.name,
          'backgroundUrl': board.backgroundUrl,
          'workspaceId': board.workspaceId,
          'workspaceName': board.workspaceName,
        });
        final uid = await serviceLocator<UserLocalDataSource>().getUserId();
        if (uid != null && context.mounted) {
          context.read<BoardCubit>().fetchBoardData(uid, '');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
                image: board.backgroundUrl != null
                    ? DecorationImage(
                        image: NetworkImage(board.backgroundUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                board.name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoardListTileFromDynamic extends StatelessWidget {
  final dynamic board;
  const BoardListTileFromDynamic({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    final String name = board.name ?? '';
    final String? coverColor = board.coverColor;
    final String? backgroundUrl = board.backgroundUrl;
    final String id = board.id ?? '';
    final color = ColorUtils.hexToColor(coverColor ?? '#0079BF');

    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(context, '/board-detail', arguments: {
          'boardId': id,
          'boardName': name,
          'backgroundUrl': backgroundUrl,
          'workspaceId': (board as dynamic).workspaceId,
          'workspaceName': (board as dynamic).workspaceName,
        });
        final uid = await serviceLocator<UserLocalDataSource>().getUserId();
        if (uid != null && context.mounted) {
          context.read<BoardCubit>().fetchBoardData(uid, '');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
                image: backgroundUrl != null
                    ? DecorationImage(
                        image: NetworkImage(backgroundUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
