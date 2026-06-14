import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../cubit/board_detail_cubit.dart';

class BoardVisibilitySheet extends StatefulWidget {
  final String currentVisibility;

  const BoardVisibilitySheet({super.key, required this.currentVisibility});

  @override
  State<BoardVisibilitySheet> createState() => _BoardVisibilitySheetState();
}

class _BoardVisibilitySheetState extends State<BoardVisibilitySheet> {
  late String _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentVisibility;
  }

  static const _options = [
    _VisibilityOption(
      key: 'Private',
      icon: Icons.lock_outline,
      title: 'Thành viên và người theo dõi',
      desc: 'Các thành viên của bảng thông tin và quản trị không gian làm việc có thể xem và sửa bảng thông tin này.',
    ),
    _VisibilityOption(
      key: 'Workspace',
      icon: Icons.group_outlined,
      title: 'Không gian làm việc',
      desc: 'Bất kỳ ai trong không gian làm việc cũng có thể xem bảng thông tin này.',
    ),
    _VisibilityOption(
      key: 'Public',
      icon: Icons.language_outlined,
      title: 'Công khai',
      desc: 'Đây là bảng công khai. Bất kỳ ai có liên kết tới bảng này đều có thể thấy được và bảng cũng sẽ hiển thị trên công cụ tìm kiếm như Google.',
    ),
  ];

  Future<void> _save(String key) async {
    if (key == _selected) {
      Navigator.pop(context);
      return;
    }
    setState(() { _selected = key; _saving = true; });
    await context.read<BoardDetailCubit>().updateBoardVisibility(key);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                Expanded(
                  child: Text('Hiển thị', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          if (_saving) const LinearProgressIndicator(),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (_, _) => const SizedBox.shrink(),
              itemCount: _options.length,
              itemBuilder: (_, i) {
                final opt = _options[i];
                final isSelected = _selected == opt.key;
                return InkWell(
                  onTap: _saving ? null : () => _save(opt.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(opt.icon, size: 22, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(opt.desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 20),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _VisibilityOption {
  final String key;
  final IconData icon;
  final String title;
  final String desc;

  const _VisibilityOption({
    required this.key,
    required this.icon,
    required this.title,
    required this.desc,
  });
}
