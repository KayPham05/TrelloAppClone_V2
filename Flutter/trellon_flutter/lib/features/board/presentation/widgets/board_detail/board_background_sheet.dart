import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/board_detail_cubit.dart';

/// Danh sách gradient template (hex start–end)
const _kGradients = [
  [Color(0xFF8B5CF6), Color(0xFFEC4899)], // purple-pink
  [Color(0xFF2563EB), Color(0xFF06B6D4)], // blue-cyan
  [Color(0xFF059669), Color(0xFF10B981)], // green
  [Color(0xFFF59E0B), Color(0xFFEF4444)], // orange-red
  [Color(0xFF6366F1), Color(0xFF8B5CF6)], // indigo-purple
  [Color(0xFF0EA5E9), Color(0xFF6366F1)], // sky-indigo
  [Color(0xFFEC4899), Color(0xFFF97316)], // pink-orange
  [Color(0xFF14B8A6), Color(0xFF0EA5E9)], // teal-sky
];

const _kStockPhotos = [
  'https://images.unsplash.com/photo-1707343843437-caacff5cfa74?q=80&w=400&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1557682250-33bd709cbe85?q=80&w=400&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=400&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1518640467707-6811f4a6ab73?q=80&w=400&auto=format&fit=crop',
];

class BoardBackgroundSheet extends StatefulWidget {
  const BoardBackgroundSheet({super.key});

  @override
  State<BoardBackgroundSheet> createState() => _BoardBackgroundSheetState();
}

class _BoardBackgroundSheetState extends State<BoardBackgroundSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    if (!mounted) return;
    setState(() => _uploading = true);
    try {
      await context.read<BoardDetailCubit>().uploadAndSetBackground(file.path);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _applyGradient(List<Color> colors) async {
    // Encode as special URL: gradient://<hexStart>:<hexEnd>
    final start = colors[0].toARGB32().toRadixString(16).padLeft(8, '0');
    final end = colors[1].toARGB32().toRadixString(16).padLeft(8, '0');
    await context.read<BoardDetailCubit>().updateBoardBackground('gradient://$start:$end');
    if (mounted) Navigator.pop(context);
  }

  Future<void> _applyPhoto(String url) async {
    await context.read<BoardDetailCubit>().updateBoardBackground(url);
    if (mounted) Navigator.pop(context);
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
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          // Header
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
                    'Phông nền bảng',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Tabs: Màu sắc | Ảnh
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryContainer,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primaryContainer,
            tabs: const [Tab(text: 'Màu sắc'), Tab(text: 'Ảnh')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Màu sắc (gradient templates)
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: _kGradients.length,
                  itemBuilder: (_, i) {
                    final g = _kGradients[i];
                    return GestureDetector(
                      onTap: () => _applyGradient(g),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(colors: g),
                        ),
                      ),
                    );
                  },
                ),

                // TAB 2: Ảnh
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text('Stock', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    ),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemCount: _kStockPhotos.length,
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _applyPhoto(_kStockPhotos[i]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _kStockPhotos[i],
                              width: 160,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text('Tuỳ chỉnh', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: _uploading ? null : _pickAndUpload,
                        child: Container(
                          width: 120,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.outlineVariant),
                            color: AppColors.surfaceContainerLow,
                          ),
                          child: _uploading
                              ? const Center(child: CircularProgressIndicator())
                              : const Icon(Icons.add, size: 32, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
