import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cover_picker_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/list_model.dart';
import '../cubit/board_detail_cubit.dart';
import '../cubit/board_detail_state.dart';
import '../widgets/board_detail_list_column.dart';
import '../widgets/board_detail_top_bar.dart';
import '../widgets/add_list_form_widget.dart';

class BoardDetailPage extends StatefulWidget {
  const BoardDetailPage({super.key});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  late BoardDetailCubit _cubit;
  bool _isAddingList = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boardId = args?['boardId'] as String? ?? '';
    final boardName = args?['boardName'] as String? ?? 'Board';
    final backgroundUrl = args?['backgroundUrl'] as String?;
    _cubit = context.read<BoardDetailCubit>();
    if (_cubit.state is BoardDetailInitial) {
      _cubit.loadBoard(
        boardId: boardId,
        boardName: boardName,
        backgroundUrl: backgroundUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardDetailCubit, BoardDetailState>(
      builder: (context, state) {
        final boardName = state is BoardDetailLoaded ? state.boardName : 'Board';
        final backgroundUrl = state is BoardDetailLoaded ? state.backgroundUrl : null;

        return Scaffold(
          backgroundColor: AppColors.primaryContainer,
          body: Container(
            decoration: backgroundUrl != null && backgroundUrl.isNotEmpty
                ? BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(backgroundUrl),
                      fit: BoxFit.cover,
                    ),
                  )
                : const BoxDecoration(color: AppColors.primaryContainer),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  BoardDetailTopBarWidget(
                    boardName: boardName,
                    onMorePressed: () => _showMoreOptions(context),
                  ),
                  Expanded(child: _buildBody(state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context) {
    CoverPickerBottomSheet.show(
      context,
      onTemplateSelected: (url) {
        _cubit.updateBackground(url);
      },
      onImagePicked: (file) {
        _cubit.uploadBackground(file.path);
      },
    );
  }

  Widget _buildBody(BoardDetailState state) {
    if (state is BoardDetailLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (state is BoardDetailError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(state.message, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => _cubit.loadBoard(boardId: '', boardName: 'Board'), child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (state is BoardDetailLoaded) {
      return _buildKanban(state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildKanban(BoardDetailLoaded state) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      itemCount: state.lists.length + 1,
      itemBuilder: (context, index) {
        if (index < state.lists.length) {
          return BoardDetailListColumn(listData: state.lists[index]);
        }
        return _buildAddListSection();
      },
    );
  }

  Widget _buildAddListSection() {
    if (_isAddingList) {
      return AddListFormWidget(
        onCancel: () => setState(() => _isAddingList = false),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _isAddingList = true),
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Thêm danh sách khác', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
