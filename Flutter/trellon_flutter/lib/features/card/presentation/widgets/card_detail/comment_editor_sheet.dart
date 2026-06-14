import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
      _focusNode.requestFocus();
      if (widget.openFilePickerOnOpen && widget.allowAttachments) {
        _pickFiles();
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
          Row(
            children: [
              Text(
                widget.initialContent == null
                    ? 'Binh luan'
                    : 'Chinh sua binh luan',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
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
              hintText: 'Nhap @username hoac @email de tag thanh vien',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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
                  onPressed: _isSubmitting ? null : _pickFiles,
                ),
              const Spacer(),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.initialContent == null ? 'Gui' : 'Luu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
