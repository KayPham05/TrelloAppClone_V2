import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/entities/card_entity.dart';
import 'mention_suggestion_list.dart';

class CommentEditorSheet extends StatefulWidget {
  final List<CardMemberEntity> mentionMembers;
  final Future<void> Function(String content, List<String> filePaths) onSubmit;
  final String? initialContent;
  final bool allowAttachments;
  final bool openFilePickerOnOpen;

  const CommentEditorSheet({
    super.key,
    required this.mentionMembers,
    required this.onSubmit,
    this.initialContent,
    this.allowAttachments = true,
    this.openFilePickerOnOpen = false,
  });

  static Future<void> show(
    BuildContext context, {
    required List<CardMemberEntity> mentionMembers,
    required Future<void> Function(String content, List<String> filePaths)
    onSubmit,
    String? initialContent,
    bool allowAttachments = true,
    bool openFilePickerOnOpen = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CommentEditorSheet(
        mentionMembers: mentionMembers,
        onSubmit: onSubmit,
        initialContent: initialContent,
        allowAttachments: allowAttachments,
        openFilePickerOnOpen: openFilePickerOnOpen,
      ),
    );
  }

  @override
  State<CommentEditorSheet> createState() => _CommentEditorSheetState();
}

class _CommentEditorSheetState extends State<CommentEditorSheet> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final List<PlatformFile> _files = [];
  ActiveMentionToken? _activeMention;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _controller.addListener(_syncMentionToken);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.openFilePickerOnOpen) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showAddAttachmentBottomSheet();
        });
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncMentionToken)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncMentionToken() {
    final selection = _controller.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      if (_activeMention != null) setState(() => _activeMention = null);
      return;
    }
    final token = detectActiveMentionToken(
      _controller.text,
      selection.baseOffset,
    );
    if (token?.start != _activeMention?.start ||
        token?.end != _activeMention?.end ||
        token?.query != _activeMention?.query) {
      setState(() => _activeMention = token);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _files.addAll(result.files.where((file) => file.path != null));
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _files.add(
          PlatformFile(
            path: pickedFile.path,
            name: pickedFile.name,
            size: 0,
          ),
        );
      });
    }
  }

  void _showAddAttachmentBottomSheet() {
    _focusNode.unfocus();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh/video'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Tài liệu/chọn File'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickFiles();
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _selectMention(CardMemberEntity member) {
    final token = _activeMention;
    if (token == null) return;
    final replacement = mentionReplacementFor(member);
    final nextText = _controller.text.replaceRange(
      token.start,
      token.end,
      replacement,
    );
    final nextOffset = token.start + replacement.length;
    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextOffset),
    );
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(content, _files.map((file) => file.path!).toList());
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final activeMention = _activeMention;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Text(
                widget.initialContent == null
                    ? 'Bình luận'
                    : 'Chỉnh sửa bình luận',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.close_rounded, size: 20, color: Colors.grey.shade700),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            minLines: 3,
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Nhập @username hoặc @email để tag thành viên',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          if (activeMention != null) ...[
            const SizedBox(height: 8),
            MentionSuggestionList(
              members: widget.mentionMembers,
              query: activeMention.query,
              onSelected: _selectMention,
            ),
          ],
          if (_files.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _files.map((file) {
                return InputChip(
                  avatar: const Icon(Icons.attach_file_rounded, size: 18),
                  label: Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  onDeleted: () => setState(() => _files.remove(file)),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.allowAttachments)
                IconButton(
                  tooltip: 'Dinh kem tep',
                  icon: const Icon(Icons.attach_file_rounded),
                  onPressed: _isSubmitting ? null : _showAddAttachmentBottomSheet,
                ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.initialContent == null ? 'Gửi' : 'Lưu',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
