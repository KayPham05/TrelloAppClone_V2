import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../domain/entities/card_entity.dart';
import '../cubit/card_detail_cubit.dart';
import '../cubit/card_detail_state.dart';
import '../widgets/card_detail/card_detail_header.dart';
import '../widgets/card_detail/card_detail_meta_grid.dart';
import '../widgets/card_detail/card_detail_description.dart';
import '../widgets/card_detail/card_detail_checklist.dart';
import '../widgets/card_detail/card_detail_attachments.dart';
import '../widgets/card_detail/card_detail_activity.dart';
import '../../../../core/widgets/cover_picker_bottom_sheet.dart';
import '../../../../core/services/authorization_service.dart';
import '../widgets/card_detail/card_member_picker_sheet.dart';
import '../widgets/card_detail/label_picker_sheet.dart';

class CardDetailPage extends StatefulWidget {
  final CardEntity card;
  final String? boardId;
  final bool isInboxCard;
  final String? boardName;
  final String? listName;
  final String? boardBackgroundUrl;
  const CardDetailPage({
    super.key,
    required this.card,
    this.boardId,
    this.isInboxCard = false,
    this.boardName,
    this.listName,
    this.boardBackgroundUrl,
  });

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late CardDetailCubit _cubit;
  bool _quickActionsExpanded = true;

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator<CardDetailCubit>()
      ..loadCardDetails(
        widget.card,
        isInboxCard: widget.isInboxCard,
        boardId: widget.boardId,
      );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boardRole = args?['boardRole'] as String?;
    final workspaceRole = args?['workspaceRole'] as String?;
    final boardName = args?['boardName'] as String?;
    final listName = args?['listName'] as String?;
    final boardBackgroundUrl = args?['boardBackgroundUrl'] as String?;

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<CardDetailCubit, CardDetailState>(
        listener: (context, state) {
          if (state is CardDetailMoved) {
            Navigator.of(context).pop(true);
          } else if (state is CardDetailArchived) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thẻ đã được lưu trữ.')),
            );
            Navigator.of(context).pop(true);
          } else if (state is CardDetailDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thẻ đã bị xóa.')),
            );
            Navigator.of(context).pop('deleted');
          } else if (state is CardDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocBuilder<CardDetailCubit, CardDetailState>(
            builder: (context, state) {
              bool canEdit = widget.isInboxCard || widget.boardId == null;
              if (!widget.isInboxCard && widget.boardId != null) {
                if (args != null &&
                    (args.containsKey('boardRole') ||
                        args.containsKey('workspaceRole'))) {
                  canEdit = AuthorizationService()
                      .canManageCards(boardRole, workspaceRole);
                } else {
                  canEdit = true;
                }
              }

              // ── Loading / Error ─────────────────────────────────────
              if (state is! CardDetailLoaded) {
                return Stack(
                  children: [
                    if (state is CardDetailError)
                      Center(
                        child: Text(state.message,
                            style: const TextStyle(color: AppColors.error)),
                      )
                    else
                      const Center(child: CircularProgressIndicator()),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.04),
                          child: CardDetailTopBar(
                              boardId: widget.boardId ?? ''),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // ── Loaded ─────────────────────────────────────────────
              final coverUrl = state.card.backgroundUrl;
              final hasCover = coverUrl != null && coverUrl.isNotEmpty;

              return Column(
                children: [
                  // ── Scrollable body ─────────────────────────────────
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Cover + top bar overlay
                              _CoverWithTopBar(
                                coverUrl: coverUrl,
                                hasCover: hasCover,
                                canEdit: canEdit,
                                boardId: widget.boardId ?? '',
                                cubit: _cubit,
                                state: state,
                                onCoverTap: () => CoverPickerBottomSheet.show(
                                  context,
                                  onTemplateSelected: (url) =>
                                      _cubit.updateBackgroundUrl(url),
                                  onImagePicked: (file) =>
                                      _cubit.uploadCover(file.path),
                                ),
                              ),

                              // Title + board row
                              CardDetailTitle(
                                title: state.card.title,
                                status: state.card.status,
                                boardName: widget.boardName ?? boardName ?? state.card.boardName,
                                listName: widget.listName ?? listName ?? state.card.listName,
                                boardBackgroundUrl:
                                    widget.boardBackgroundUrl ?? boardBackgroundUrl ?? state.card.boardBackgroundUrl,
                                boardId: widget.boardId ?? state.card.boardId,
                                cubit: _cubit,
                                onStatusToggle: (s) => _cubit.updateStatus(s),
                              ),

                              const Divider(height: 24, indent: 16, endIndent: 16),

                              // ── Các thao tác nhanh (quick actions) ──
                              _QuickActionsSection(
                                expanded: _quickActionsExpanded,
                                onToggle: () => setState(
                                    () => _quickActionsExpanded = !_quickActionsExpanded),
                                canEdit: canEdit,
                                onChecklistTap: () {},
                                onAttachmentTap: () {
                                  // trigger attachment picker via cubit attachment sheet
                                },
                                onMembersTap: () {
                                  if (widget.boardId == null) return;
                                  CardMemberPickerSheet.show(
                                    context,
                                    allBoardMembers: state.potentialMembers,
                                    currentCardMembers: state.members,
                                    canManage: canEdit,
                                    onMemberToggled: (member) {
                                      final isAssigned = state.members.any(
                                          (m) => m.userUId == member.userUId);
                                      if (isAssigned) {
                                        _cubit.removeMember(
                                            member.userUId, widget.boardId!);
                                      } else {
                                        _cubit.addMember(
                                            member.userUId, widget.boardId!);
                                      }
                                    },
                                  );
                                },
                              ),

                              const Divider(height: 1, indent: 16, endIndent: 16),

                              // ── Description ──────────────────────────
                              CardDetailDescription(
                                description: state.card.description ?? '',
                                onSave: canEdit
                                    ? (v) => _cubit.updateDescription(v)
                                    : null,
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),

                              // ── Labels / Members / Dates ─────────────
                              CardDetailMetaGrid(
                                members: state.members,
                                labels: state.card.labels,
                                dueDate: state.card.dueDate,
                                onAddMember: canEdit
                                    ? () {
                                        if (widget.boardId == null) return;
                                        CardMemberPickerSheet.show(
                                          context,
                                          allBoardMembers:
                                              state.potentialMembers,
                                          currentCardMembers: state.members,
                                          canManage: canEdit,
                                          onMemberToggled: (member) {
                                            final isAssigned = state.members
                                                .any((m) =>
                                                    m.userUId == member.userUId);
                                            if (isAssigned) {
                                              _cubit.removeMember(
                                                  member.userUId,
                                                  widget.boardId!);
                                            } else {
                                              _cubit.addMember(
                                                  member.userUId,
                                                  widget.boardId!);
                                            }
                                          },
                                        );
                                      }
                                    : () {},
                                onMemberRoleChanged: canEdit
                                    ? (m, r) {
                                        if (widget.boardId == null) return;
                                        _cubit.updateMemberRole(
                                            userUId: m.userUId,
                                            newRole: r,
                                            boardId: widget.boardId!);
                                      }
                                    : (m, r) {},
                                onRemoveMember: canEdit
                                    ? (m) {
                                        if (widget.boardId == null) return;
                                        _cubit.removeMember(
                                            m.userUId, widget.boardId!);
                                      }
                                    : (m) {},
                                onAddLabel: canEdit
                                    ? () => LabelPickerSheet.show(
                                          context,
                                          selectedLabels: state.card.labels,
                                          onLabelToggled: (l, c) =>
                                              _cubit.toggleLabel(l, c),
                                        )
                                    : () {},
                                onDateChanged: canEdit
                                    ? (d) => _cubit.updateDueDate(d)
                                    : (d) {},
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),

                              // ── Checklist ─────────────────────────────
                              CardDetailChecklist(
                                initialItems: state.todos
                                    .map((t) => CardDetailChecklistItem(
                                          id: t.id,
                                          title: t.title,
                                          checked: t.isCompleted,
                                        ))
                                    .toList(),
                                onCheckChanged: canEdit
                                    ? (id, v) =>
                                        _cubit.toggleTodoItem(id, v)
                                    : null,
                                onAddTodo: canEdit
                                    ? (c) => _cubit.addTodoItem(c)
                                    : null,
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),

                              // ── Attachments ────────────────────────────
                              const CardDetailAttachments(),
                              const Divider(height: 1, indent: 16, endIndent: 16),

                              // ── Activity ───────────────────────────────
                              const SizedBox(height: 4),
                              CardDetailActivityList(
                                activities: state.comments
                                    .map((c) => CardActivityItemData(
                                          authorName:
                                              c.authorName ?? 'User',
                                          initial: (c.authorName ?? 'U')
                                              .substring(0, 1),
                                          time: _formatTime(c.createdAt),
                                          content: c.content,
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),

                        // Top bar overlay
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: hasCover
                                ? CardDetailTopBar(
                                    boardId: widget.boardId ?? '',
                                    allowJoinCard: false,
                                    canManage: canEdit,
                                    onMembersTap: () =>
                                        _openMemberPicker(context, state, canEdit),
                                    onChecklistTap: () {},
                                    onAttachmentTap: () {},
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200)),
                                    ),
                                    child: CardDetailTopBar(
                                      boardId: widget.boardId ?? '',
                                      allowJoinCard: false,
                                      canManage: canEdit,
                                      onMembersTap: () =>
                                          _openMemberPicker(context, state, canEdit),
                                      onChecklistTap: () {},
                                      onAttachmentTap: () {},
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Sticky comment bar ──────────────────────────────
                  SafeArea(
                    top: false,
                    child: const CardDetailCommentBar(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openMemberPicker(BuildContext context, CardDetailLoaded state, bool canEdit) {
    if (widget.boardId == null) return;
    CardMemberPickerSheet.show(
      context,
      allBoardMembers: state.potentialMembers,
      currentCardMembers: state.members,
      canManage: canEdit,
      onMemberToggled: (member) {
        final isAssigned =
            state.members.any((m) => m.userUId == member.userUId);
        if (isAssigned) {
          _cubit.removeMember(member.userUId, widget.boardId!);
        } else {
          _cubit.addMember(member.userUId, widget.boardId!);
        }
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds} giây trước';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Quick actions collapsible section ─────────────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final bool canEdit;
  final VoidCallback onChecklistTap;
  final VoidCallback onAttachmentTap;
  final VoidCallback onMembersTap;

  const _QuickActionsSection({
    required this.expanded,
    required this.onToggle,
    required this.canEdit,
    required this.onChecklistTap,
    required this.onAttachmentTap,
    required this.onMembersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          child: Row(
            children: [
              Text('Các thao tác nhanh',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              const Spacer(),
              IconButton(
                icon: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 22,
                    color: Colors.grey.shade600),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
        // Grid of action chips (only when expanded)
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickChip(
                  icon: Icons.check_box_outlined,
                  label: 'Thêm Danh sách cô...',
                  color: const Color(0xFF43A047),
                  onTap: onChecklistTap,
                ),
                _QuickChip(
                  icon: Icons.attach_file_outlined,
                  label: 'Thêm Tệp đính kèm',
                  color: const Color(0xFF00ACC1),
                  onTap: onAttachmentTap,
                ),
                _QuickChip(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Thành viên',
                  color: const Color(0xFF8E24AA),
                  onTap: onMembersTap,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ── Cover + overlay top bar ────────────────────────────────────────────────────
class _CoverWithTopBar extends StatelessWidget {
  final String? coverUrl;
  final bool hasCover;
  final bool canEdit;
  final String boardId;
  final CardDetailCubit cubit;
  final CardDetailLoaded state;
  final VoidCallback onCoverTap;

  const _CoverWithTopBar({
    required this.coverUrl,
    required this.hasCover,
    required this.canEdit,
    required this.boardId,
    required this.cubit,
    required this.state,
    required this.onCoverTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: !hasCover, // push content below status bar only when no cover
      child: hasCover
          ? CardDetailCoverSection(
              imageUrl: coverUrl,
              canEdit: canEdit,
              onTap: onCoverTap,
            )
          // No cover: show grey placeholder (same height) with "Ảnh bìa" button
          : CardDetailCoverSection(
              imageUrl: null,
              canEdit: canEdit,
              onTap: onCoverTap,
            ),
    );
  }
}
