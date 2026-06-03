
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class CardDetailDescription extends StatelessWidget {
  final String description;
  final ValueChanged<String>? onSave;

  const CardDetailDescription({
    super.key,
    required this.description,
    this.onSave,
  });

  void _openEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CardDescriptionEditorModal(
          initialDescription: description,
          onSave: onSave,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = description.isEmpty;
    return GestureDetector(
      onTap: () => _openEditor(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(Icons.menu_rounded,
                    size: 20, color: Colors.grey.shade500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    isEmpty ? 'Thêm mô tả' : description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: isEmpty
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                    ),
                    maxLines: isEmpty ? 1 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardDescriptionEditorModal extends StatefulWidget {
  final String initialDescription;
  final ValueChanged<String>? onSave;

  const CardDescriptionEditorModal({
    super.key,
    required this.initialDescription,
    this.onSave,
  });

  @override
  State<CardDescriptionEditorModal> createState() => _CardDescriptionEditorModalState();
}

class _CardDescriptionEditorModalState extends State<CardDescriptionEditorModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (widget.onSave != null) {
      widget.onSave!(_controller.text);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {    
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F7), // iOS system background color
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  // X close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E5EA),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF3C3C43),
                      ),
                    ),
                  ),
                  // Title
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Mô tả',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
                  // Xong button
                  GestureDetector(
                    onTap: _handleSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        'Xong',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // No divider - just spacing
            // Text area card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.5,
                      color: const Color(0xFF1C1C1E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập mô tả chi tiết...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF8E8E93),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

