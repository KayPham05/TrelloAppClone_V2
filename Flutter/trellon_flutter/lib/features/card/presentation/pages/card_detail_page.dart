import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

// ── Mock data ──────────────────────────────────────────────────────────────

class _ChecklistItem {
  final String title;
  bool checked;
  _ChecklistItem({required this.title, this.checked = false});
}

class _ActivityItem {
  final String initial;
  final Color avatarColor;
  final String authorName;
  final String action;
  final String? comment;
  final String time;

  const _ActivityItem({
    required this.initial,
    required this.avatarColor,
    required this.authorName,
    required this.action,
    this.comment,
    required this.time,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({super.key});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  bool _dueDateChecked = false;
  final ValueNotifier<int> _checklistVersionNotifier = ValueNotifier<int>(0);
  final _commentController = TextEditingController();

  final List<_ChecklistItem> _checklistItems = [
    _ChecklistItem(
      title: 'Xây dựng hệ thống màu sắc (surface đến surface-bright)',
      checked: false,
    ),
    _ChecklistItem(title: 'Áp dụng hệ thống font Inter', checked: true),
    _ChecklistItem(title: 'Kiểm tra tất cả border 1px', checked: true),
    _ChecklistItem(
      title: 'Thiết kế responsive cho mobile & tablet',
      checked: false,
    ),
    _ChecklistItem(title: 'Review với design lead', checked: false),
  ];

  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      initial: 'S',
      avatarColor: Color(0xFF8B5CF6),
      authorName: 'Sarah Chen',
      action: 'đã cập nhật mô tả',
      time: '22 Th10 lúc 2:45 CH',
    ),
    _ActivityItem(
      initial: 'M',
      avatarColor: Color(0xFF0C56D0),
      authorName: 'Marcus Wright',
      action: 'đã bình luận:',
      comment:
          'Tôi đã tải lên moodboard mới cho hướng thiết kế editorial. Cho tôi biết nếu độ tương phản màu xanh chính có vẻ ổn.',
      time: '22 Th10 lúc 3:12 CH',
    ),
  ];

  int get _checkedCount => _checklistItems.where((i) => i.checked).length;
  double get _progress =>
      _checklistItems.isEmpty ? 0 : _checkedCount / _checklistItems.length;

  @override
  void dispose() {
    _checklistVersionNotifier.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.cardShadow,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 24),
                      _buildMetaGrid(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildChecklistSection(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildAttachmentsSection(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildActivitySection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
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
            'Workspace',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
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
        ],
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.subtitles_outlined,
          color: AppColors.onSurfaceVariant,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xây dựng hệ thống thiết kế workspace phong cách editorial',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'trong cột '),
                    TextSpan(
                      text: 'Đang làm',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.primaryContainer,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Members
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('THÀNH VIÊN'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _avatarChip('A', const Color(0xFF3B82F6)),
                  const SizedBox(width: 4),
                  _avatarChip('B', const Color(0xFF8B5CF6)),
                  const SizedBox(width: 4),
                  _addChip(),
                ],
              ),
            ],
          ),
        ),
        // Labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('NHÃN'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _labelChip('Thiết kế', const Color(0xFF2563EB)),
                  _labelChip('Ưu tiên', const Color(0xFF0D9488)),
                  _addChip(small: true),
                ],
              ),
            ],
          ),
        ),
        // Due date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('NGÀY HẾT HẠN'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _dueDateChecked = !_dueDateChecked),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _dueDateChecked
                              ? AppColors.primaryContainer
                              : Colors.transparent,
                          border: Border.all(
                            color: _dueDateChecked
                                ? AppColors.primaryContainer
                                : AppColors.outlineVariant,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: _dueDateChecked
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 10,
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24/10/2023',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'QUÁ HẠN',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.notes_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text('Mô tả', style: _sectionTitleStyle()),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
              ),
              child: Text(
                'Chỉnh sửa',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.transparent),
              ),
              child: Text(
                'UI mới phải chuyển đổi từ dạng lưới truyền thống sang không gian làm việc editorial cao cấp. Tập trung vào sự chuyển sắc tông màu thay vì đường viền cứng. Dùng surface-container-lowest cho các card để tạo chiều sâu và rõ ràng...',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSection() {
    return ValueListenableBuilder<int>(
      valueListenable: _checklistVersionNotifier,
      builder: (context, _, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text('Danh sách kiểm tra', style: _sectionTitleStyle()),
                const Spacer(),
                Text(
                  '${(_progress * 100).round()}%',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceContainer,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Checklist items
                  ...List.generate(_checklistItems.length, (i) {
                    final item = _checklistItems[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              item.checked = !item.checked;
                              _checklistVersionNotifier.value++;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: item.checked
                                    ? AppColors.primaryContainer
                                    : Colors.transparent,
                                border: Border.all(
                                  color: item.checked
                                      ? AppColors.primaryContainer
                                      : AppColors.outlineVariant,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: item.checked
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: item.checked
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.onSurface,
                                decoration: item.checked
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Add item button
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Thêm mục',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.attach_file_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text('Đính kèm', style: _sectionTitleStyle()),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attachment item
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 80,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.onSurfaceVariant,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'workspace_moodboard_v2.png',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(text: 'Thêm 2 giờ trước • '),
                                TextSpan(
                                  text: 'Bình luận',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    decoration: TextDecoration.underline,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const TextSpan(text: ' • '),
                                TextSpan(
                                  text: 'Xóa',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    decoration: TextDecoration.underline,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Add attachment button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Thêm đính kèm',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.list_alt_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text('Hoạt động', style: _sectionTitleStyle()),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Xem chi tiết',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Comment input
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
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
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Viết bình luận...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Activity items
        ..._activities.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: a.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      a.initial,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: a.authorName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: ' ${a.action}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (a.comment != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06191C1E),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            a.comment!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(text: a.time),
                            if (a.comment != null) ...[
                              const TextSpan(text: ' • '),
                              TextSpan(
                                text: 'Trả lời',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  decoration: TextDecoration.underline,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }

  TextStyle _sectionTitleStyle() => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  Widget _avatarChip(String initial, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _addChip({bool small = false}) {
    final size = small ? 28.0 : 30.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.add_rounded,
        color: AppColors.onSurfaceVariant,
        size: 16,
      ),
    );
  }

  Widget _labelChip(String text, Color color) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.outlineVariant.withValues(alpha: 0.3),
      height: 1,
    );
  }
}
