import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/data_sources/user_local_data_source.dart';
import '../../../../../init_dependencies.dart';
import '../../../../card/domain/entities/card_entity.dart';
import '../../../data/datasources/board_remote_data_source.dart';
import '../../../domain/entities/board_member.dart';
import '../../../domain/entities/list_entity.dart';
import '../../cubit/board_filter_cubit.dart';
import '../../cubit/board_member_cubit.dart';
import '../../models/board_filter_label_option.dart';

enum _OpenDropdown { none, members, labels }

class BoardFilterSheet extends StatefulWidget {
  final String boardId;
  final List<ListEntity> lists;
  final BoardFilterState initialState;
  final ValueChanged<BoardFilterState> onChanged;
  final VoidCallback onClear;

  const BoardFilterSheet({
    super.key,
    required this.boardId,
    required this.lists,
    required this.initialState,
    required this.onChanged,
    required this.onClear,
  });

  static Future<void> show(
    BuildContext context, {
    required String boardId,
    required List<ListEntity> lists,
    required BoardFilterState initialState,
    required ValueChanged<BoardFilterState> onChanged,
    required VoidCallback onClear,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BoardFilterSheet(
        boardId: boardId,
        lists: lists,
        initialState: initialState,
        onChanged: onChanged,
        onClear: onClear,
      ),
    );
  }

  @override
  State<BoardFilterSheet> createState() => _BoardFilterSheetState();
}

class _BoardFilterSheetState extends State<BoardFilterSheet> {
  late final BoardFilterCubit _filterCubit;
  late final TextEditingController _queryCtrl;
  final _memberSearchCtrl = TextEditingController();
  final _labelSearchCtrl = TextEditingController();
  final _memberFocusNode = FocusNode();
  final _labelFocusNode = FocusNode();
  Timer? _debounce;
  StreamSubscription<BoardFilterState>? _filterSub;
  String _memberSearch = '';
  String _labelSearch = '';
  String _currentUserUId = '';
  _OpenDropdown _openDropdown = _OpenDropdown.none;

  bool get _hasOpenDropdown => _openDropdown != _OpenDropdown.none;

  @override
  void initState() {
    super.initState();
    _filterCubit = BoardFilterCubit(widget.initialState);
    _queryCtrl = TextEditingController(text: widget.initialState.query);
    serviceLocator<UserLocalDataSource>().getUserId().then((value) {
      if (!mounted) return;
      setState(() => _currentUserUId = value ?? '');
    });

    _filterSub = _filterCubit.stream.listen((state) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        widget.onChanged(state);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _filterSub?.cancel();
    _queryCtrl.dispose();
    _memberSearchCtrl.dispose();
    _labelSearchCtrl.dispose();
    _memberFocusNode.dispose();
    _labelFocusNode.dispose();
    _filterCubit.close();
    super.dispose();
  }

  List<CardLabelEntity> get _labels {
    final map = <String, CardLabelEntity>{};
    for (final list in widget.lists) {
      for (final card in list.cards) {
        for (final label in card.labels) {
          map[label.id] = label;
        }
      }
    }
    final labels = map.values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    return labels;
  }

  List<BoardFilterLabelOption> get _groupedLabelOptions {
    return BoardFilterLabelGrouper.group(
      _labels.map(
        (label) => BoardFilterRawLabel(
          id: label.id,
          title: label.title,
          colorCode: label.colorCode,
        ),
      ),
    );
  }

  void _clearAll() {
    _queryCtrl.clear();
    _memberSearchCtrl.clear();
    _labelSearchCtrl.clear();
    _closeDropdowns();
    _filterCubit.clearAll();
    _debounce?.cancel();
    widget.onClear();
  }

  void _closeDropdowns() {
    if (!mounted) return;
    setState(() {
      _openDropdown = _OpenDropdown.none;
      _memberSearch = '';
      _labelSearch = '';
      _memberSearchCtrl.clear();
      _labelSearchCtrl.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _toggleDropdown(_OpenDropdown dropdown) {
    setState(() {
      if (_openDropdown == dropdown) {
        _openDropdown = _OpenDropdown.none;
        _memberSearch = '';
        _labelSearch = '';
        _memberSearchCtrl.clear();
        _labelSearchCtrl.clear();
      } else {
        _openDropdown = dropdown;
        if (dropdown == _OpenDropdown.members) {
          _labelSearch = '';
          _labelSearchCtrl.clear();
        } else {
          _memberSearch = '';
          _memberSearchCtrl.clear();
        }
      }
    });

    if (_openDropdown == _OpenDropdown.members) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _memberFocusNode.requestFocus();
      });
    } else if (_openDropdown == _OpenDropdown.labels) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _labelFocusNode.requestFocus();
      });
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenH = mediaQuery.size.height;
    final viewInsets = mediaQuery.viewInsets.bottom;
    final sheetHeight = (screenH * 0.92 - viewInsets).clamp(
      screenH * 0.55,
      screenH * 0.92,
    );

    return PopScope<void>(
      canPop: !_hasOpenDropdown,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _hasOpenDropdown) _closeDropdowns();
      },
      child: BlocProvider.value(
        value: _filterCubit,
        child: BlocProvider(
          create: (_) => BoardMemberCubit(
            dataSource: serviceLocator<BoardRemoteDataSource>(),
            userLocalDataSource: serviceLocator<UserLocalDataSource>(),
          )..loadMembers(widget.boardId),
          child: Container(
            height: sheetHeight.toDouble(),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1F2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BlocBuilder<BoardFilterCubit, BoardFilterState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _buildHandle(),
                    _buildHeader(state),
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Từ khóa'),
                            _buildKeywordField(),
                            _sectionTitle('Thành viên'),
                            _buildMemberFilters(state),
                            _sectionTitle('Trạng thái thẻ'),
                            _buildStatusFilters(state),
                            _sectionTitle('Thời hạn'),
                            _buildDueDateFilters(state),
                            _sectionTitle('Nhãn'),
                            _buildLabelFilters(state),
                            _sectionTitle('Chế độ khớp'),
                            _buildMatchMode(state),
                          ],
                        ),
                      ),
                    ),
                    _buildFooter(state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BoardFilterState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Lọc thẻ',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (state.isActive)
            TextButton(onPressed: _clearAll, child: const Text('Xóa bộ lọc')),
          IconButton(
            tooltip: 'Đóng',
            onPressed: () {
              _closeDropdowns();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildKeywordField() {
    return TextField(
      controller: _queryCtrl,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Tìm theo tiêu đề hoặc mô tả'),
      onTap: _closeDropdowns,
      onChanged: _filterCubit.setQuery,
    );
  }

  Widget _buildMemberFilters(BoardFilterState state) {
    return BlocBuilder<BoardMemberCubit, BoardMemberState>(
      builder: (context, memberState) {
        if (memberState is BoardMemberLoading) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          );
        }
        if (memberState is! BoardMemberLoaded) {
          return const Text(
            'Không thể tải thành viên',
            style: TextStyle(color: Colors.white54),
          );
        }

        final allOtherMembers = memberState.members
            .where((m) => m.userUId != _currentUserUId)
            .toList();
        final allOtherIds = allOtherMembers.map((m) => m.userUId).toSet();
        final selectedOtherCount = state.selectedMemberUIds
            .intersection(allOtherIds)
            .length;
        final filteredMembers = allOtherMembers.where((m) {
          final needle = _normalizeSearch(_memberSearch);
          if (needle.isEmpty) return true;
          return _normalizeSearch(m.userName).contains(needle) ||
              _normalizeSearch(m.email).contains(needle);
        }).toList();

        return Column(
          children: [
            _checkboxTile(
              value: state.noMembers,
              title: 'Chưa có thành viên',
              onTap: _filterCubit.toggleNoMembers,
            ),
            _checkboxTile(
              value: state.assignedToMe,
              title: 'Thẻ được giao cho tôi',
              onTap: _filterCubit.toggleAssignedToMe,
            ),
            _checkboxTile(
              value: _parentCheckboxValue(
                selectedOtherCount,
                allOtherIds.length,
              ),
              title: 'Thành viên khác',
              subtitle: selectedOtherCount > 0
                  ? 'Đã chọn $selectedOtherCount thành viên'
                  : null,
              tristate: true,
              onTap: () {
                final shouldSelectAll =
                    selectedOtherCount != allOtherIds.length;
                _filterCubit.selectMembers(
                  shouldSelectAll ? allOtherIds : const <String>{},
                );
              },
            ),
            _dropdownAnchor(
              text: _selectedMemberText(selectedOtherCount),
              isOpen: _openDropdown == _OpenDropdown.members,
              onTap: () => _toggleDropdown(_OpenDropdown.members),
            ),
            if (_openDropdown == _OpenDropdown.members)
              _memberDropdown(filteredMembers, allOtherMembers, state),
          ],
        );
      },
    );
  }

  Widget _memberDropdown(
    List<BoardMember> filteredMembers,
    List<BoardMember> allOtherMembers,
    BoardFilterState state,
  ) {
    return _dropdownPanel(
      searchField: TextField(
        controller: _memberSearchCtrl,
        focusNode: _memberFocusNode,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration('Tìm kiếm thành viên'),
        onChanged: (value) => setState(() => _memberSearch = value),
      ),
      emptyMessage: allOtherMembers.isEmpty
          ? 'Không có thành viên khác trong bảng'
          : 'Không tìm thấy thành viên',
      isEmpty: filteredMembers.isEmpty,
      children: filteredMembers.map((member) {
        final selected = state.selectedMemberUIds.contains(member.userUId);
        return _memberOption(member, selected);
      }).toList(),
    );
  }

  Widget _memberOption(BoardMember member, bool selected) {
    final initial = member.userName.trim().isNotEmpty
        ? member.userName.trim().characters.first.toUpperCase()
        : 'U';
    return InkWell(
      onTap: () => _filterCubit.toggleMember(member.userUId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => _filterCubit.toggleMember(member.userUId),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.blueLight,
              backgroundImage: member.avatarUrl?.isNotEmpty == true
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl?.isNotEmpty == true
                  ? null
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.userName.isEmpty ? 'Thành viên' : member.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (member.email.isNotEmpty)
                    Text(
                      member.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilters(BoardFilterState state) {
    return Column(
      children: BoardCompletionFilter.values.map((filter) {
        final selected = state.completionFilter == filter;
        return InkWell(
          onTap: () {
            _closeDropdowns();
            _filterCubit.setCompletionFilter(filter);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? AppColors.blueLight : Colors.white54,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    filter.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDueDateFilters(BoardFilterState state) {
    return Column(
      children: DueDateFilter.values.map((filter) {
        return _checkboxTile(
          value: state.dueDateFilters.contains(filter),
          title: filter.label,
          onTap: () => _filterCubit.toggleDueDate(filter),
        );
      }).toList(),
    );
  }

  Widget _buildLabelFilters(BoardFilterState state) {
    final labelOptions = _groupedLabelOptions;
    final filteredLabels = labelOptions.where((option) {
      return option.matchesQuery(_labelSearch);
    }).toList();
    final allLabelIds = labelOptions.map((option) => option.key).toSet();
    final selectedCount = state.selectedLabelGroupKeys
        .intersection(allLabelIds)
        .length;

    return Column(
      children: [
        _checkboxTile(
          value: state.noLabels,
          title: 'Chưa có nhãn',
          onTap: _filterCubit.toggleNoLabels,
        ),
        _checkboxTile(
          value: _parentCheckboxValue(selectedCount, allLabelIds.length),
          title: 'Nhãn đã chọn',
          subtitle: selectedCount > 0 ? 'Đã chọn $selectedCount nhãn' : null,
          tristate: true,
          onTap: () {
            final shouldSelectAll = selectedCount != allLabelIds.length;
            _filterCubit.selectLabelGroups(
              shouldSelectAll
                  ? {
                      for (final option in labelOptions)
                        option.key: option.cardLabelUIds,
                    }
                  : const {},
            );
          },
        ),
        _dropdownAnchor(
          text: _selectedLabelText(selectedCount),
          isOpen: _openDropdown == _OpenDropdown.labels,
          onTap: () => _toggleDropdown(_OpenDropdown.labels),
        ),
        if (_openDropdown == _OpenDropdown.labels)
          _labelDropdown(filteredLabels, labelOptions, state),
      ],
    );
  }

  Widget _labelDropdown(
    List<BoardFilterLabelOption> filteredLabels,
    List<BoardFilterLabelOption> allLabels,
    BoardFilterState state,
  ) {
    return _dropdownPanel(
      searchField: TextField(
        controller: _labelSearchCtrl,
        focusNode: _labelFocusNode,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration('Tìm kiếm nhãn'),
        onChanged: (value) => setState(() => _labelSearch = value),
      ),
      emptyMessage: allLabels.isEmpty
          ? 'Bảng này chưa có nhãn'
          : 'Không tìm thấy nhãn',
      isEmpty: filteredLabels.isEmpty,
      children: filteredLabels.map((option) {
        final selected = state.selectedLabelGroupKeys.contains(option.key);
        return _labelOption(option, selected);
      }).toList(),
    );
  }

  Widget _labelOption(BoardFilterLabelOption label, bool selected) {
    return InkWell(
      onTap: () =>
          _filterCubit.toggleLabelGroup(label.key, label.cardLabelUIds),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) =>
                  _filterCubit.toggleLabelGroup(label.key, label.cardLabelUIds),
            ),
            Container(
              width: 42,
              height: 22,
              decoration: BoxDecoration(
                color: _labelColor(label.colorCode),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label.title.isEmpty ? 'Nhãn' : label.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchMode(BoardFilterState state) {
    return SegmentedButton<BoardFilterMatchMode>(
      segments: BoardFilterMatchMode.values
          .map((mode) => ButtonSegment(value: mode, label: Text(mode.label)))
          .toList(),
      selected: {state.matchMode},
      onSelectionChanged: (value) {
        _closeDropdowns();
        _filterCubit.setMatchMode(value.first);
      },
    );
  }

  Widget _buildFooter(BoardFilterState state) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2D3447))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAll,
              child: const Text('Xóa bộ lọc'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _closeDropdowns();
                widget.onChanged(state);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xong'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkboxTile({
    required bool? value,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    bool tristate = false,
  }) {
    return CheckboxListTile(
      value: value,
      tristate: tristate,
      onChanged: (_) {
        _closeDropdowns();
        onTap();
      },
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(color: Colors.white54)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.blueLight,
    );
  }

  Widget _dropdownAnchor({
    required String text,
    required bool isOpen,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF252B3A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOpen ? AppColors.blueLight : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownPanel({
    required Widget searchField,
    required bool isEmpty,
    required String emptyMessage,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: const Color(0xFF202638),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          searchField,
          const SizedBox(height: 8),
          Flexible(
            child: isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: children,
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF252B3A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.blueLight),
      ),
    );
  }

  bool? _parentCheckboxValue(int selectedCount, int totalCount) {
    if (selectedCount == 0 || totalCount == 0) return false;
    if (selectedCount == totalCount) return true;
    return null;
  }

  String _selectedMemberText(int selectedCount) {
    if (selectedCount == 0) return 'Chọn thành viên';
    return 'Đã chọn $selectedCount thành viên';
  }

  String _selectedLabelText(int selectedCount) {
    if (selectedCount == 0) return 'Chọn nhãn';
    return 'Đã chọn $selectedCount nhãn';
  }

  Color _labelColor(String colorCode) {
    final normalized = colorCode.trim().replaceFirst('#', '');
    if (normalized.length == 6) {
      final value = int.tryParse('FF$normalized', radix: 16);
      if (value != null) return Color(value);
    }
    return AppColors.blueLight;
  }

  String _normalizeSearch(String value) {
    return _stripVietnameseMarks(value).trim().toLowerCase();
  }

  String _stripVietnameseMarks(String value) {
    const from =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const to =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString();
  }
}
