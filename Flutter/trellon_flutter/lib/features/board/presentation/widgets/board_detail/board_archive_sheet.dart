import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../../init_dependencies.dart';
import '../../../data/datasources/board_remote_data_source.dart';
import '../../../../../features/card/data/models/card_model.dart';

class BoardArchiveSheet extends StatefulWidget {
  final String boardId;

  const BoardArchiveSheet({super.key, required this.boardId});

  @override
  State<BoardArchiveSheet> createState() => _BoardArchiveSheetState();
}

class _BoardArchiveSheetState extends State<BoardArchiveSheet>
    with SingleTickerProviderStateMixin {
  List<CardModel> _allCards = [];
  List<CardModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ds = serviceLocator<BoardRemoteDataSource>();
    final cards = await ds.getArchivedCards(widget.boardId);
    if (mounted) {
      setState(() {
        _allCards = cards;
        _filtered = cards;
        _loading = false;
      });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _allCards
          : _allCards.where((c) => c.title.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _restore(CardModel card) async {
    final ds = serviceLocator<BoardRemoteDataSource>();
    final userDs = serviceLocator<UserLocalDataSource>();
    final userUId = await userDs.getUserId() ?? '';
    try {
      await ds.restoreCard(cardId: card.id, userUId: userUId);
      setState(() {
        _allCards.removeWhere((c) => c.id == card.id);
        _filtered.removeWhere((c) => c.id == card.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Đã khôi phục thẻ "${card.title}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Khôi phục thất bại'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 7 / 8,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Lưu trữ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Lọc thẻ theo tên...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primaryContainer,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primaryContainer,
            tabs: const [
              Tab(text: 'Thẻ'),
              Tab(text: 'Danh sách'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Thẻ
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final c = _filtered[i];
                          return ListTile(
                            title: Text(
                              c.title,
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                            trailing: TextButton(
                              onPressed: () => _restore(c),
                              child: const Text(
                                'Khôi phục',
                                style: TextStyle(
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                // Danh sách – Coming soon
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.list_alt,
                        size: 48,
                        color: AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tính năng đang phát triển',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.archive_outlined,
            size: 64,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thẻ lưu trữ nào',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
