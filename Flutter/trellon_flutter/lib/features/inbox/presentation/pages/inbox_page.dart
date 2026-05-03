import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../init_dependencies.dart';
import '../../../card/presentation/pages/card_detail_page.dart';
import '../../../card/presentation/widgets/card_overview_widget.dart';
import '../bloc/inbox_cubit.dart';
import '../bloc/inbox_state.dart';
import '../widgets/add_input_widget.dart';


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
    // Deprecated for ID based
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                   Expanded(
                    child: Text(
                      'Hộp thư đến',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.surfaceVariant),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                     decoration: BoxDecoration(
                      border: Border.all(color: AppColors.surfaceVariant),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            // ── Search ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: const TextField(
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm',
                    hintStyle: TextStyle(color: AppColors.outline),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                    return SingleChildScrollView(
                      controller: _inboxScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < items.length; i++) ...[
                              Dismissible(
                                key: Key(items[i].id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete_outline, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  context.read<InboxCubit>().deleteCard(items[i].id);
                                },
                                child: RepaintBoundary(
                                  child: CardOverviewWidget(
                                    card: items[i],
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CardDetailPage(card: items[i], isInboxCard: true),
                                        ),
                                      );
                                      if (context.mounted) {
                                        context.read<InboxCubit>().fetchInboxCards();
                                      }
                                    },
                                    onToggleComplete: (val) {
                                      context.read<InboxCubit>().toggleCardStatus(items[i].id, val);
                                    },
                                  ),
                                ),
                              ),
                              if (i < items.length - 1) const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
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
