import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

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
                  'Bình luận',
                  style: GoogleFonts.inter(
                    fontSize: 16,
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
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF334155),
              backgroundImage:
                  item.avatarUrl != null && item.avatarUrl!.isNotEmpty
                  ? NetworkImage(item.avatarUrl!)
                  : null,
              child: item.avatarUrl == null || item.avatarUrl!.isEmpty
                  ? Text(
                      item.initial.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      Text(
                        item.updatedAt == null
                            ? item.time
                            : '${item.time} · đã chỉnh sửa',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF0C66E4),
                        ),
                      ),
                      if (item.isCurrentUser) ...[
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: Colors.grey.shade500,
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
                              child: Text('Chỉnh sửa'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (item.isEditing)
                    _buildEditor(context)
                  else
                    _buildContent(item),
                  if (item.attachments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Column(
                      children: item.attachments
                          .map(
                            (file) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _AttachmentChip(
                                file: file,
                                canDelete: item.isCurrentUser && item.isEditing,
                                onDelete: () => context
                                    .read<CardDetailCubit>()
                                    .deleteCommentAttachment(
                                      item.commentId,
                                      file.id,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
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

  bool _isImage(String url) {
    final ext = url.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  String _getFileExt(String fileName) {
    if (!fileName.contains('.')) return 'FILE';
    final parts = fileName.split('.');
    String ext = parts.last.toUpperCase();
    return ext.length > 3 ? ext.substring(0, 3) : ext;
  }

  Color _getColorForExt(String fileName) {
    final ext = _getFileExt(fileName);
    if (ext == 'PDF') return const Color(0xFF3B82F6);
    if (['JPG', 'PNG', 'JPE', 'WEBP'].contains(ext)) return const Color(0xFF10B981);
    if (['DOC', 'DOCX'].contains(ext)) return const Color(0xFF2563EB);
    return const Color(0xFFF97316);
  }

  void _openFile(BuildContext context) async {
    final isImg = _isImage(file.url);
    final ext = _getFileExt(file.fileName);
    final isPdf = ext == 'PDF';

    if (isImg) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: Image.network(file.url),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              _buildFileInfoOverlay(true),
            ],
          ),
        ),
      );
    } else if (isPdf) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                const PDF().cachedFromUrl(
                  file.url,
                  placeholder: (progress) => Center(child: Text('$progress %')),
                  errorWidget: (error) => Center(child: Text(error.toString())),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54, size: 30),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                _buildFileInfoOverlay(false),
              ],
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: const Text('Không có bản xem trước nào cho tệp đính kèm này.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFileInfoOverlay(bool isTransparentBg) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: isTransparentBg 
              ? BorderRadius.zero 
              : const BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              file.fileName,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (file.description != null && file.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  file.description!,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isImg = _isImage(file.url);
    final ext = _getFileExt(file.fileName);
    final color = _getColorForExt(file.fileName);

    return InkWell(
      onTap: () => _openFile(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              image: isImg
                  ? DecorationImage(
                      image: NetworkImage(file.url),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: isImg
                ? null
                : Center(
                    child: Text(
                      ext,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName.isNotEmpty ? file.fileName : 'Attachment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (isImg)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Hình ảnh',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Tệp đính kèm',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    ),
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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF334155),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'U',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _openEditor(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      'Bình luận...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: 'Đính kèm tệp',
                  onPressed: allowAttachments
                      ? () => _openEditor(context, openFilePicker: true)
                      : null,
                  icon: Icon(
                    Icons.attach_file_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
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

class CardDetailCommentInput extends StatelessWidget {
  const CardDetailCommentInput({super.key});

  @override
  Widget build(BuildContext context) =>
      const CardDetailCommentBar(mentionMembers: []);
}
