import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../init_dependencies.dart';
import '../../../../board/data/datasources/board_remote_data_source.dart';
import '../../cubit/card_detail_cubit.dart';
import '../../cubit/card_detail_state.dart';
import 'move_card_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CardDetailTopBar  –  X | [spacer] | ⊕  ⋯
// Overlay buttons on top of the cover area (transparent background).
// Uses popup menus that match the reference images.
// ─────────────────────────────────────────────────────────────────────────────
class CardDetailTopBar extends StatelessWidget {
  final String boardId;
  final bool allowJoinCard;
  final bool canManage;
  final VoidCallback? onMembersTap;
  final VoidCallback? onChecklistTap;
  final VoidCallback? onAttachmentTap;

  const CardDetailTopBar({
    super.key,
    required this.boardId,
    this.allowJoinCard = false,
    this.canManage = false,
    this.onMembersTap,
    this.onChecklistTap,
    this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // X — close
          _OverlayIconButton(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          // ⊕ — add popup
          _AddPopupButton(
            boardId: boardId,
            allowJoinCard: allowJoinCard,
            onMembersTap: onMembersTap,
            onChecklistTap: onChecklistTap,
            onAttachmentTap: onAttachmentTap,
          ),
          const SizedBox(width: 4),
          // ⋯ — more popup
          _MorePopupButton(
            boardId: boardId,
            canManage: canManage,
          ),
        ],
      ),
    );
  }
}

// ── Transparent overlay icon button ──────────────────────────────────────────
class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OverlayIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black54)]),
      ),
    );
  }
}

// ── ⊕ Popup menu ─────────────────────────────────────────────────────────────
class _AddPopupButton extends StatelessWidget {
  final String boardId;
  final bool allowJoinCard;
  final VoidCallback? onMembersTap;
  final VoidCallback? onChecklistTap;
  final VoidCallback? onAttachmentTap;

  const _AddPopupButton({
    required this.boardId,
    required this.allowJoinCard,
    this.onMembersTap,
    this.onChecklistTap,
    this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardDetailCubit>();
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'join':
            cubit.joinCard(boardId);
            break;
          case 'members':
            onMembersTap?.call();
            break;
          case 'checklist':
            onChecklistTap?.call();
            break;
          case 'attachment':
            onAttachmentTap?.call();
            break;
        }
      },
      itemBuilder: (_) => [
        if (allowJoinCard)
          _popupItem('join', Icons.person_add_alt_1_outlined, 'Tham gia thẻ'),
        _popupItem('members', Icons.person_outline, 'Thành viên'),
        _popupItem('checklist', Icons.check_box_outlined, 'Thêm Danh sách công việc'),
        _popupItem('attachment', Icons.attach_file_outlined, 'Thêm Tệp đính kèm'),
      ],
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.add, color: Colors.white, size: 22,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
      ),
    );
  }
}

// ── ⋯ Popup menu ─────────────────────────────────────────────────────────────
class _MorePopupButton extends StatelessWidget {
  final String boardId;
  final bool canManage;

  const _MorePopupButton({required this.boardId, required this.canManage});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardDetailCubit>();
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      onSelected: (value) async {
        switch (value) {
          case 'move':
            final s = cubit.state;
            if (s is CardDetailLoaded) {
              MoveCardSheet.show(
                context,
                card: s.card,
                currentBoardId: boardId,
                boardDataSource: serviceLocator<BoardRemoteDataSource>(),
                cubit: cubit,
              );
            }
            break;
          case 'copy':
          case 'copylink':
          case 'share':
          case 'view':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
            break;
          case 'archive':
            cubit.archiveCard();
            break;
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Xóa thẻ'),
                content: const Text('Bạn có chắc muốn xóa thẻ này? Hành động này không thể hoàn tác.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            if (confirmed == true) cubit.deleteCard();
            break;
        }
      },
      itemBuilder: (_) => [
        _popupItem('move', Icons.arrow_forward_outlined, 'Di chuyển thẻ'),
        _popupItem('copy', Icons.copy_outlined, 'Sao chép thẻ'),
        _popupItem('copylink', Icons.link_outlined, 'Sao chép liên kết'),
        _popupItem('share', Icons.share_outlined, 'Chia sẻ liên kết'),
        _popupItem('view', Icons.remove_red_eye_outlined, 'Xem'),
        _popupItem('archive', Icons.archive_outlined, 'Lưu trữ thẻ'),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(children: [
            const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Text('Xóa thẻ', style: GoogleFonts.inter(color: Colors.red, fontSize: 15)),
          ]),
        ),
      ],
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 22,
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)]),
      ),
    );
  }
}

PopupMenuItem<String> _popupItem(String value, IconData icon, String label) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(children: [
      Icon(icon, size: 20, color: Colors.black87),
      const SizedBox(width: 12),
      Text(label, style: GoogleFonts.inter(fontSize: 15, color: Colors.black87)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CardDetailCoverSection  –  Full-width cover with "Ảnh bìa" placeholder
// ─────────────────────────────────────────────────────────────────────────────
class CardDetailCoverSection extends StatelessWidget {
  final String? imageUrl;
  final bool canEdit;
  final VoidCallback? onTap;

  const CardDetailCoverSection({
    super.key,
    this.imageUrl,
    this.canEdit = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background: image or grey placeholder
          if (hasImage)
            CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
          else
            Container(color: Colors.grey[300]),

          // "Ảnh bìa" label at bottom-left
          if (canEdit)
            Positioned(
              bottom: 12,
              left: 16,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image_outlined, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('Ảnh bìa',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CardDetailTitle  –  Circle checkbox LEFT · title text · status chip below
// ─────────────────────────────────────────────────────────────────────────────
class CardDetailTitle extends StatefulWidget {
  final String title;
  final String status;
  final String? boardName;
  final String? listName;
  final String? boardBackgroundUrl;
  final String? boardId;
  final CardDetailCubit? cubit;
  final ValueChanged<String>? onStatusToggle;
  final bool isArchived;
  final VoidCallback? onUnarchive;

  const CardDetailTitle({
    super.key,
    required this.title,
    required this.status,
    this.boardName,
    this.listName,
    this.boardBackgroundUrl,
    this.boardId,
    this.cubit,
    this.onStatusToggle,
    this.isArchived = false,
    this.onUnarchive,
  });

  @override
  State<CardDetailTitle> createState() => _CardDetailTitleState();
}

class _CardDetailTitleState extends State<CardDetailTitle> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_controller.text != widget.title) {
          widget.cubit?.updateTitle(_controller.text);
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant CardDetailTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title && !_focusNode.hasFocus) {
      _controller.text = widget.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.status.toLowerCase() == 'hoan_thanh' ||
        widget.status.toLowerCase() == 'hoàn thành' ||
        widget.status.toLowerCase() == 'completed';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: circle checkbox + title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular completion checkbox (LEFT side)
              GestureDetector(
                onTap: widget.onStatusToggle != null
                    ? () => widget.onStatusToggle!(isCompleted ? 'dang_lam' : 'hoan_thanh')
                    : null,
                child: Container(
                  margin: const EdgeInsets.only(top: 4, right: 12),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              // Title text
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    _focusNode.unfocus();
                  },
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.25,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status chip
          GestureDetector(
            onTap: widget.onStatusToggle != null
                ? () => widget.onStatusToggle!(isCompleted ? 'dang_lam' : 'hoan_thanh')
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isCompleted) ...[
                    const Icon(Icons.check_circle, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    isCompleted ? 'HOÀN THÀNH' : widget.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? Colors.white : AppColors.onSurfaceVariant,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Board row: thumbnail + board/workspace name · "Di chuyển"
          if (widget.boardId != null || widget.boardName != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: (widget.boardId != null && widget.cubit != null)
                  ? () {
                      if (widget.isArchived) {
                        widget.cubit!.unarchiveCard();
                        if (widget.onUnarchive != null) {
                          widget.onUnarchive!();
                        }
                      } else {
                        final s = widget.cubit!.state;
                        if (s is CardDetailLoaded) {
                          MoveCardSheet.show(
                            context,
                            card: s.card,
                            currentBoardId: widget.boardId!,
                            boardDataSource: serviceLocator<BoardRemoteDataSource>(),
                            cubit: widget.cubit!,
                          );
                        }
                      }
                    }
                  : null,
              child: Row(
                children: [
                   // Board background thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 40,
                      height: 32,
                      child: (widget.boardBackgroundUrl != null && widget.boardBackgroundUrl!.isNotEmpty)
                          ? Image.network(
                              widget.boardBackgroundUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _colorPlaceholder(),
                            )
                          : _colorPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Board + workspace name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.boardName ?? 'Đang tải...',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.listName != null)
                          Text(
                            widget.listName!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // "Di chuyển" or "Khôi phục" link
                  if (widget.boardId != null && widget.cubit != null)
                    Text(
                      widget.isArchived ? 'Khôi phục' : 'Di chuyển',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: widget.isArchived ? Colors.green : const Color(0xFF1565C0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _colorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey.shade400, Colors.blueGrey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
