import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../bloc/inbox_cubit.dart';
import '../bloc/inbox_state.dart';
import '../widgets/add_input_widget.dart';
import '../widgets/inbox_item_widget.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<InboxCubit>(),
      child: const InboxView(),
    );
  }
}

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  final TextEditingController _addController = TextEditingController();
  final ScrollController _inboxScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<InboxCubit>().fetchInboxCards();
  }

  void _onToggleComplete(int index, bool newValue) {
    // Logic for toggling complete
  }

  void _onSubmittedNewCard(String val) {
    if (val.trim().isNotEmpty) {
      context.read<InboxCubit>().addCardToInbox(val.trim());
      _addController.clear();
    }
  }

  @override
  void dispose() {
    _addController.dispose();
    _inboxScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Hộp thư đến',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.view_list_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // ── Search ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Items List ───────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<InboxCubit, InboxState>(
                builder: (context, state) {
                  if (state is InboxLoading || state is InboxInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is InboxError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is InboxEmpty) {
                    return const Center(
                      child: Text(
                        "Hộp thư của bạn đang trống",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  } else if (state is InboxLoaded) {
                    final items = state.cards;
                    return ListView.builder(
                      controller: _inboxScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == items.length) {
                          return const SizedBox(height: 80);
                        }
                        return RepaintBoundary(
                          child: InboxItemWidget(
                            item: items[i],
                            index: i,
                            totalCount: items.length,
                            onToggleComplete: (val) =>
                                _onToggleComplete(i, val),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            // ── Add Card Bottom Input ────────────────────────────────────
            AddInputWidget(
              controller: _addController,
              onSubmitted: _onSubmittedNewCard,
            ),
          ],
        ),
      ),
    );
  }
}
