import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/card_detail/card_member_picker_sheet.dart';
import '../widgets/card_detail/label_picker_sheet.dart';

class CardDetailPage extends StatefulWidget {
  final CardEntity card;
  final String? boardId;
  const CardDetailPage({super.key, required this.card, this.boardId});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late CardDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = serviceLocator<CardDetailCubit>()..loadCardDetails(widget.card);
    if (widget.boardId != null) {
      _cubit.loadPotentialMembers(widget.boardId!);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.surface, // Standard white surface for Lucid Sanctuary
        body: BlocBuilder<CardDetailCubit, CardDetailState>(
          builder: (context, state) {
            if (state is CardDetailLoaded) {
              return Stack(
                 children: [
                    // List of contents
                     Positioned.fill(
                      child: SingleChildScrollView(
                         padding: EdgeInsets.fromLTRB(0, state.card.backgroundUrl != null && state.card.backgroundUrl!.isNotEmpty ? 0 : 80, 0, 100),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [
                               if (state.card.backgroundUrl != null && state.card.backgroundUrl!.isNotEmpty)
                                 GestureDetector(
                                   onTap: () {
                                     CoverPickerBottomSheet.show(
                                       context,
                                       onTemplateSelected: (url) {
                                         context.read<CardDetailCubit>().updateBackgroundUrl(url);
                                       },
                                       onImagePicked: (file) {
                                         context.read<CardDetailCubit>().uploadCover(file.path);
                                       },
                                     );
                                   },
                                   child: CachedNetworkImage(
                                     imageUrl: state.card.backgroundUrl!,
                                     height: 180,
                                     width: double.infinity,
                                     fit: BoxFit.cover,
                                   ),
                                 ),
                               if (state.card.backgroundUrl == null || state.card.backgroundUrl!.isEmpty)
                                 const SizedBox(height: 80),
                               Padding(
                                 padding: const EdgeInsets.only(top: 16),
                                 child: CardDetailTitle(
                                   title: state.card.title,
                                   status: state.card.status,
                                   onStatusToggle: (newStatus) => context.read<CardDetailCubit>().updateStatus(newStatus),
                                 ),
                               ),
                               const SizedBox(height: 32),
                               CardDetailMetaGrid(
                                 members: state.members, 
                                 labels: state.card.labels,
                                 dueDate: state.card.dueDate,
                                 onAddMember: () {
                                   if (widget.boardId == null) return;
                                   CardMemberPickerSheet.show(
                                     context,
                                     allBoardMembers: state.potentialMembers,
                                     currentCardMembers: state.members,
                                     onMemberToggled: (member) {
                                       final isAssigned = state.members.any((m) => m.userUId == member.userUId);
                                       if (isAssigned) {
                                          _cubit.removeMember(member.userUId, widget.boardId!);
                                       } else {
                                          _cubit.addMember(member.userUId, widget.boardId!);
                                       }
                                     },
                                   );
                                 },
                                 onAddLabel: () {
                                   LabelPickerSheet.show(
                                     context,
                                     selectedLabels: state.card.labels,
                                     onLabelToggled: (label, colorHex) => _cubit.toggleLabel(label, colorHex),
                                   );
                                 },
                                 onDateChanged: (date) => _cubit.updateDueDate(date),
                               ),
                               const SizedBox(height: 32),
                               CardDetailDescription(
                                 description: state.card.description ?? '',
                                 onSave: (newDesc) => context.read<CardDetailCubit>().updateDescription(newDesc),
                               ),
                               const SizedBox(height: 32),
                               CardDetailChecklist(
                                 initialItems: state.todos.map((t) => CardDetailChecklistItem(id: t.id, title: t.title, checked: t.isCompleted)).toList(),
                                 onCheckChanged: (id, isCompleted) => context.read<CardDetailCubit>().toggleTodoItem(id, isCompleted),
                                 onAddTodo: (content) => context.read<CardDetailCubit>().addTodoItem(content),
                               ),
                               const SizedBox(height: 32),
                               const CardDetailAttachments(),
                               const SizedBox(height: 32),
                               CardDetailActivityList(
                                 activities: state.comments.map((c) => CardActivityItemData(
                                   authorName: c.authorName ?? 'User',
                                   initial: (c.authorName ?? 'U').substring(0, 1),
                                   time: '${c.createdAt.day}/${c.createdAt.month} ${c.createdAt.hour}:${c.createdAt.minute}',
                                   content: c.content,
                                 )).toList(),
                               ),
                           ],
                         ),
                      ),
                    ),
                     // Top App Bar overlapping
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                           children: [
                             const SizedBox(width: 8),
                             IconButton(
                               icon: const Icon(Icons.arrow_back, color: Colors.white),
                               onPressed: () => Navigator.pop(context),
                             ),
                             const Spacer(),
                             IconButton(
                               icon: const Icon(Icons.image, color: Colors.white),
                               onPressed: () {
                                 CoverPickerBottomSheet.show(
                                   context,
                                   onTemplateSelected: (url) {
                                     context.read<CardDetailCubit>().updateBackgroundUrl(url);
                                   },
                                   onImagePicked: (file) {
                                     context.read<CardDetailCubit>().uploadCover(file.path);
                                   },
                                 );
                               },
                             ),
                             const SizedBox(width: 8),
                           ],
                        ),
                      ),
                    ),
                 ]
              );
            } else if (state is CardDetailError) {
              return Stack(
                children: [
                   Center(child: Text(state.message, style: const TextStyle(color: AppColors.error))),
                   Positioned(
                     top: 0,
                     left: 0,
                     right: 0,
                     child: CardDetailTopBar(title: widget.card.title),
                   )
                ]
              );
            }
            return Stack(
                children: [
                   const Center(child: CircularProgressIndicator()),
                   Positioned(
                     top: 0,
                     left: 0,
                     right: 0,
                     child: CardDetailTopBar(title: widget.card.title),
                   )
                ]
              );
          },
        ),
      ),
    );
  }
}
