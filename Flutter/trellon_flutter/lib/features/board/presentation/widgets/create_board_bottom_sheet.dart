import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../workspace/domain/entities/workspace_entity.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/board_cubit.dart';
import 'workspace_picker_sheet.dart';
import 'visibility_picker_sheet.dart';

// Modular widgets
import 'create_board/create_board_main_page.dart';
import 'create_board/create_board_sub_page.dart';

/// Shows the Create Board bottom sheet. Must be called within a context that
/// provides both [WorkspaceCubit] (for workspace list) and [BoardCubit] (for creating).
Future<void> showCreateBoardBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<BoardCubit>(),
      child: BlocProvider.value(
        value: context.read<WorkspaceCubit>(),
        child: const _CreateBoardBottomSheetContent(),
      ),
    ),
  );
}

class _CreateBoardBottomSheetContent extends StatefulWidget {
  const _CreateBoardBottomSheetContent();

  @override
  State<_CreateBoardBottomSheetContent> createState() =>
      _CreateBoardBottomSheetContentState();
}

class _CreateBoardBottomSheetContentState
    extends State<_CreateBoardBottomSheetContent> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  WorkspaceEntity? _selectedWorkspace;
  String _selectedVisibility = 'Private';
  Color _selectedColor = const Color(0xFF2563EB);
  bool _isCreating = false;

  static const List<Color> _presetColors = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFDB2777),
    Color(0xFFD97706),
    Color(0xFF0EA5E9),
    Color(0xFF111827),
    Color(0xFF4F46E5),
  ];

  String get _colorHex =>
      '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wsState = context.read<WorkspaceCubit>().state;
      if (wsState is WorkspaceLoaded) {
        final all = [...wsState.personal, ...wsState.team];
        if (all.isNotEmpty && _selectedWorkspace == null) {
          setState(() => _selectedWorkspace = all.first);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên bảng')),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      if (_selectedWorkspace == null) {
        // PERSONAL BOARD (No Workspace)
        await context.read<BoardCubit>().createPersonalBoard(
          name: name,
          visibility: _selectedVisibility,
        );
      } else {
        // WORKSPACE BOARD (Personal or Team Workspace)
        final isPersonal = _selectedWorkspace?.type == WorkspaceType.personal;
        await context.read<BoardCubit>().createBoard(
          name: name,
          workspaceId: _selectedWorkspace!.id,
          isPersonal: isPersonal,
          visibility: _selectedVisibility,
          coverColor: _colorHex,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BoardCubit, BoardState>(
      listener: (ctx, state) {
        if (state is BoardCreated) Navigator.pop(ctx);
        if (state is BoardError && _isCreating) {
          setState(() => _isCreating = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        snap: true,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CreateBoardMainPage(
                  scrollController: scrollController,
                  nameController: _nameController,
                  selectedWorkspace: _selectedWorkspace,
                  selectedVisibility: _selectedVisibility,
                  selectedColor: _selectedColor,
                  presetColors: _presetColors,
                  isCreating: _isCreating,
                  onSelectColor: (c) => setState(() => _selectedColor = c),
                  onTapWorkspace: () => _toPage(1),
                  onTapVisibility: () => _toPage(2),
                  onSubmit: _submit,
                ),
                CreateBoardSubPage(
                  title: 'Không gian làm việc',
                  onBack: () => _toPage(0),
                  child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                    builder: (ctx, wsState) {
                      final workspaces = wsState is WorkspaceLoaded
                          ? [...wsState.personal, ...wsState.team]
                          : <WorkspaceEntity>[];
                      return WorkspacePickerSheet(
                        workspaces: workspaces,
                        selectedWorkspace: _selectedWorkspace,
                        onSelected: (ws) {
                          setState(() => _selectedWorkspace = ws);
                          _toPage(0);
                        },
                      );
                    },
                  ),
                ),
                CreateBoardSubPage(
                  title: 'Hiển thị',
                  onBack: () => _toPage(0),
                  child: VisibilityPickerSheet(
                    selectedValue: _selectedVisibility,
                    onSelected: (v) {
                      setState(() => _selectedVisibility = v);
                      _toPage(0);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
