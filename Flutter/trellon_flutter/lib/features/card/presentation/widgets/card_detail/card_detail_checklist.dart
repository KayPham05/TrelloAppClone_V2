import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
class CardDetailChecklistItem {
  final String title;
  bool checked;
  CardDetailChecklistItem({required this.title, this.checked = false});
}

class CardDetailChecklist extends StatefulWidget {
  final List<CardDetailChecklistItem> initialItems;
  const CardDetailChecklist({super.key, required this.initialItems});

  @override
  State<CardDetailChecklist> createState() => _CardDetailChecklistState();
}

class _CardDetailChecklistState extends State<CardDetailChecklist> {
  late List<CardDetailChecklistItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
  }

  double get _progress =>
      _items.isEmpty ? 0 : _items.where((i) => i.checked).length / _items.length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_box_outlined,
                    size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'DANH SÁCH CÔNG VIỆC',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add,
                            size: 14, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 4),
                        Text(
                          'THÊM',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerLow,
                color: const Color(0xFF1D4ED8),
              ),
            ),
            const SizedBox(height: 24),
            ..._items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                item.checked = !item.checked;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: item.checked
                                    ? const Color(0xFF1D4ED8)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: item.checked
                                      ? const Color(0xFF1D4ED8)
                                      : AppColors.outlineVariant,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: item.checked
                                  ? const Icon(Icons.check,
                                      size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                height: 1.5,
                              ),
                            ),
                          )
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
