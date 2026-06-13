import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/card_entity.dart';
import '../../cubit/card_detail_cubit.dart';
import 'comment_editor_sheet.dart';

class CardActivityItemData {
  final String commentId;
  final String userUId;
  final String authorName;
  final String? avatarUrl;
  final String initial;
  final String content;
  final String time;
  final DateTime? updatedAt;
  final bool isCurrentUser;
  final bool isEditing;
  final List<FileUrlEntity> attachments;

  CardActivityItemData({
    required this.commentId,
    required this.userUId,
    required this.authorName,
    this.avatarUrl,
    required this.initial,
    required this.content,
    required this.time,
    this.updatedAt,
    required this.isCurrentUser,
    required this.isEditing,
    this.attachments = const [],
  });
}

class CardDetailActivityList extends StatelessWidget {
  final List<CardActivityItemData> activities;

  const CardDetailActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Icon(
                Icons.format_list_bulleted_rounded,
                size: 20,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hoat dong',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.settings_outlined,
                size: 20,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Chua co binh luan nao.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          )
        else
          ...activities.map((item) => _ActivityItem(item: item)),
      ],
    );
  }
}

class _ActivityItem extends StatefulWidget {
  final CardActivityItemData item;

  const _ActivityItem({required this.item});

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem> {
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.item.content);
  }

  @override
  void didUpdateWidget(covariant _ActivityItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.content != widget.item.content &&
        !widget.item.isEditing) {
      _editController.text = widget.item.content;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFF334155),
            backgroundImage:
                item.avatarUrl != null && item.avatarUrl!.isNotEmpty
                ? NetworkImage(item.avatarUrl!)
                : null,
            child: item.avatarUrl == null || item.avatarUrl!.isEmpty
                ? Text(
                    item.initial.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.authorName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (item.isCurrentUser)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.grey.shade600,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.read<CardDetailCubit>().startEditComment(
                              item.commentId,
                            );
                          } else if (value == 'delete') {
                            _confirmDelete(context);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Chinh sua'),
                          ),
                          PopupMenuItem(value: 'delete', child: Text('Xoa')),
                        ],
                      ),
                  ],
                ),
                if (item.isEditing)
                  _buildEditor(context)
                else
                  _buildContent(item),
                if (item.attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.attachments
                        .map(
                          (file) => _AttachmentChip(
                            file: file,
                            canDelete: item.isCurrentUser,
                            onDelete: () => context
                                .read<CardDetailCubit>()
                                .deleteCommentAttachment(
                                  item.commentId,
                                  file.id,
                                ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  item.updatedAt == null
                      ? item.time
                      : '${item.time} · da chinh sua',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CardActivityItemData item) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
        children: _buildMentionSpans(item.content),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _editController,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () =>
                  context.read<CardDetailCubit>().cancelEditComment(),
              child: const Text('Huy'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final content = _editController.text.trim();
                if (content.isNotEmpty) {
                  context.read<CardDetailCubit>().updateComment(
                    widget.item.commentId,
                    content,
                  );
                }
              },
              child: const Text('Luu'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoa binh luan?'),
        content: const Text('Binh luan se bi xoa vinh vien.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<CardDetailCubit>().deleteComment(
        widget.item.commentId,
      );
    }
  }

  List<TextSpan> _buildMentionSpans(String text) {
    final regex = RegExp(
      r'@([A-Za-z0-9._%+\-]+(?:@[A-Za-z0-9.\-]+\.[A-Za-z]{2,})?)',
    );
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            color: Color(0xFF0C66E4),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return spans;
  }
}

class _AttachmentChip extends StatelessWidget {
  final FileUrlEntity file;
  final bool canDelete;
  final VoidCallback onDelete;

  const _AttachmentChip({
    required this.file,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: const Icon(Icons.attach_file_rounded, size: 18),
      label: Text(
        file.fileName.isNotEmpty ? file.fileName : 'Attachment',
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(fontSize: 12),
      ),
      onDeleted: canDelete ? onDelete : null,
    );
  }
}

class CardDetailCommentBar extends StatelessWidget {
  final List<CardMemberEntity> mentionMembers;
  final bool allowAttachments;

  const CardDetailCommentBar({
    super.key,
    required this.mentionMembers,
    this.allowAttachments = true,
  });

  Future<void> _openEditor(
    BuildContext context, {
    bool openFilePicker = false,
  }) {
    return CommentEditorSheet.show(
      context,
      mentionMembers: mentionMembers,
      allowAttachments: allowAttachments,
      openFilePickerOnOpen: openFilePicker,
      onSubmit: (content, filePaths) {
        return context.read<CardDetailCubit>().addComment(
          content,
          filePaths: filePaths,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'U',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openEditor(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Binh luan...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Dinh kem tep',
            onPressed: allowAttachments
                ? () => _openEditor(context, openFilePicker: true)
                : null,
            icon: Icon(
              Icons.attach_file_outlined,
              size: 22,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class CardDetailCommentInput extends StatelessWidget {
  const CardDetailCommentInput({super.key});

  @override
  Widget build(BuildContext context) =>
      const CardDetailCommentBar(mentionMembers: []);
}
