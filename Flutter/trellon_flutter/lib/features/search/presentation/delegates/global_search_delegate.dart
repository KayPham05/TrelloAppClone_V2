import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../init_dependencies.dart';
import '../../data/datasources/search_remote_data_source.dart';
import '../../data/models/search_result_model.dart';


class GlobalSearchDelegate extends SearchDelegate<String> {
  final String userUId;
  late final SearchRemoteDataSource _dataSource;

  GlobalSearchDelegate({required this.userUId}) : super(searchFieldLabel: 'Tìm kiếm Boards, Cards...') {
    _dataSource = SearchRemoteDataSource(client: serviceLocator<Dio>());
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Nhập từ khóa để tìm kiếm', style: TextStyle(color: Colors.grey)));
    }

    return FutureBuilder<SearchResultModel>(
      future: _dataSource.search(query.trim(), userUId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        } else if (snapshot.hasError) {
          return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
        } else if (!snapshot.hasData || (snapshot.data!.boards.isEmpty && snapshot.data!.cards.isEmpty)) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Không tìm thấy kết quả nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        final result = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (result.boards.isNotEmpty) ...[
              const Text('BOARDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              ...result.boards.map((b) => _buildBoardCard(context, b)),
              const SizedBox(height: 24),
            ],
            if (result.cards.isNotEmpty) ...[
              const Text('CARDS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              const SizedBox(height: 8),
              ...result.cards.map((c) => _buildCardCard(context, c)),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(color: const Color(0xFFF8F9FA)); // canvas white-ish
    }
    // We can show real-time suggestions by calling buildResults, or just prompt them to press search.
    // For a snappy experience, we'll return buildResults directly if query is long enough.
    if (query.trim().length > 1) {
      return buildResults(context);
    }
    return Container();
  }

  Widget _buildBoardCard(BuildContext context, SearchBoardModel board) {
    return InkWell(
      onTap: () {
        close(context, '');
        Navigator.pushNamed(context, '/board-detail', arguments: {
          'boardId': board.boardUId,
          'boardName': board.boardName,
          'backgroundUrl': board.backgroundUrl,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // rounded.lg
          border: Border.all(color: const Color(0xFFE2E8F0)), // hairline
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // surface
                borderRadius: BorderRadius.circular(8),
                image: board.backgroundUrl != null
                    ? DecorationImage(image: NetworkImage(board.backgroundUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: board.backgroundUrl == null ? const Icon(Icons.dashboard, color: Colors.grey) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                board.boardName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)), // ink
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardCard(BuildContext context, SearchCardModel card) {
    return InkWell(
      onTap: () {
        close(context, '');
        if (card.boardUId != null) {
          // Typically we pass boardId and card, or we just navigate to the board
          // For now, let's navigate to the board so the user can see it in context
          Navigator.pushNamed(context, '/board-detail', arguments: {
            'boardId': card.boardUId,
            'boardName': card.boardName ?? 'Board',
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // rounded.lg
          border: Border.all(color: const Color(0xFFE2E8F0)), // hairline
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            ),
            if (card.boardName != null) ...[
              const SizedBox(height: 4),
              Text(
                'trong bảng ${card.boardName}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)), // slate
              ),
            ],
          ],
        ),
      ),
    );
  }
}
