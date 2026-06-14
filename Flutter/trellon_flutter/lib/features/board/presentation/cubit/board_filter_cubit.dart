import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/card_status_values.dart';
import '../../data/models/board_card_filter_request.dart';

enum DueDateFilter { overdue, noDate, nextWeek, nextMonth }

extension DueDateFilterLabel on DueDateFilter {
  String get label {
    switch (this) {
      case DueDateFilter.overdue:
        return 'Quá hạn';
      case DueDateFilter.noDate:
        return 'Không có thời hạn';
      case DueDateFilter.nextWeek:
        return 'Hết hạn trong tuần tới';
      case DueDateFilter.nextMonth:
        return 'Hết hạn trong tháng tới';
    }
  }

  String get apiValue {
    switch (this) {
      case DueDateFilter.overdue:
        return 'overdue';
      case DueDateFilter.noDate:
        return 'no_due_date';
      case DueDateFilter.nextWeek:
        return 'next_week';
      case DueDateFilter.nextMonth:
        return 'next_month';
    }
  }
}

enum BoardCompletionFilter { completed, incomplete }

extension BoardCompletionFilterLabel on BoardCompletionFilter {
  String get label => this == BoardCompletionFilter.completed
      ? 'Hoàn thành'
      : 'Chưa hoàn thành';

  String get apiValue => this == BoardCompletionFilter.completed
      ? CardStatusValues.completed
      : 'incomplete';
}

enum BoardFilterMatchMode { exact, any }

extension BoardFilterMatchModeLabel on BoardFilterMatchMode {
  String get label =>
      this == BoardFilterMatchMode.exact ? 'Khớp chính xác' : 'Khớp bất kỳ';

  String get apiValue => this == BoardFilterMatchMode.exact ? 'exact' : 'any';
}

class BoardFilterState extends Equatable {
  final String query;
  final bool noMembers;
  final bool assignedToMe;
  final Set<String> selectedMemberUIds;
  final Set<String> selectedLabelIds;
  final Set<String> selectedLabelGroupKeys;
  final List<BoardCardLabelFilterGroupRequest> selectedLabelGroups;
  final BoardCompletionFilter? completionFilter;
  final Set<DueDateFilter> dueDateFilters;
  final bool noLabels;
  final BoardFilterMatchMode matchMode;

  const BoardFilterState({
    this.query = '',
    this.noMembers = false,
    this.assignedToMe = false,
    this.selectedMemberUIds = const {},
    this.selectedLabelIds = const {},
    this.selectedLabelGroupKeys = const {},
    this.selectedLabelGroups = const [],
    this.completionFilter,
    this.dueDateFilters = const {},
    this.noLabels = false,
    this.matchMode = BoardFilterMatchMode.exact,
  });

  bool get isActive =>
      query.trim().isNotEmpty ||
      noMembers ||
      assignedToMe ||
      selectedMemberUIds.isNotEmpty ||
      selectedLabelIds.isNotEmpty ||
      selectedLabelGroupKeys.isNotEmpty ||
      completionFilter != null ||
      dueDateFilters.isNotEmpty ||
      noLabels;

  BoardCardFilterRequest toRequest() {
    return BoardCardFilterRequest(
      keyword: query.trim(),
      noMembers: noMembers,
      assignedToMe: assignedToMe,
      memberUIds: selectedMemberUIds,
      completionStatus: completionFilter?.apiValue,
      dueDateFilters: dueDateFilters.map((f) => f.apiValue).toSet(),
      noLabels: noLabels,
      labelUIds: selectedLabelIds,
      selectedLabelGroups: selectedLabelGroups,
      matchMode: matchMode.apiValue,
    );
  }

  BoardFilterState copyWith({
    String? query,
    bool? noMembers,
    bool? assignedToMe,
    Set<String>? selectedMemberUIds,
    Set<String>? selectedLabelIds,
    Set<String>? selectedLabelGroupKeys,
    List<BoardCardLabelFilterGroupRequest>? selectedLabelGroups,
    BoardCompletionFilter? completionFilter,
    bool clearCompletionFilter = false,
    Set<DueDateFilter>? dueDateFilters,
    bool? noLabels,
    BoardFilterMatchMode? matchMode,
  }) {
    return BoardFilterState(
      query: query ?? this.query,
      noMembers: noMembers ?? this.noMembers,
      assignedToMe: assignedToMe ?? this.assignedToMe,
      selectedMemberUIds: selectedMemberUIds ?? this.selectedMemberUIds,
      selectedLabelIds: selectedLabelIds ?? this.selectedLabelIds,
      selectedLabelGroupKeys:
          selectedLabelGroupKeys ?? this.selectedLabelGroupKeys,
      selectedLabelGroups: selectedLabelGroups ?? this.selectedLabelGroups,
      completionFilter: clearCompletionFilter
          ? null
          : (completionFilter ?? this.completionFilter),
      dueDateFilters: dueDateFilters ?? this.dueDateFilters,
      noLabels: noLabels ?? this.noLabels,
      matchMode: matchMode ?? this.matchMode,
    );
  }

  @override
  List<Object?> get props => [
    query,
    noMembers,
    assignedToMe,
    selectedMemberUIds,
    selectedLabelIds,
    selectedLabelGroupKeys,
    selectedLabelGroups,
    completionFilter,
    dueDateFilters,
    noLabels,
    matchMode,
  ];
}

class BoardFilterCubit extends Cubit<BoardFilterState> {
  BoardFilterCubit([super.initialState = const BoardFilterState()]);

  void setQuery(String q) => emit(state.copyWith(query: q));

  void toggleNoMembers() => emit(state.copyWith(noMembers: !state.noMembers));

  void toggleAssignedToMe() =>
      emit(state.copyWith(assignedToMe: !state.assignedToMe));

  void toggleMember(String userUId) {
    final updated = Set<String>.from(state.selectedMemberUIds);
    updated.contains(userUId) ? updated.remove(userUId) : updated.add(userUId);
    emit(state.copyWith(selectedMemberUIds: updated));
  }

  void selectMembers(Iterable<String> userUIds) {
    emit(state.copyWith(selectedMemberUIds: userUIds.toSet()));
  }

  void toggleLabel(String labelId) {
    final updated = Set<String>.from(state.selectedLabelIds);
    updated.contains(labelId) ? updated.remove(labelId) : updated.add(labelId);
    emit(state.copyWith(selectedLabelIds: updated));
  }

  void selectLabels(Iterable<String> labelIds) {
    emit(state.copyWith(selectedLabelIds: labelIds.toSet()));
  }

  void toggleLabelGroup(String key, Iterable<String> cardLabelUIds) {
    final updatedKeys = Set<String>.from(state.selectedLabelGroupKeys);
    final updatedGroups = <String, BoardCardLabelFilterGroupRequest>{};
    var groupIndex = 0;
    for (final groupKey in state.selectedLabelGroupKeys) {
      if (groupIndex < state.selectedLabelGroups.length) {
        updatedGroups[groupKey] = state.selectedLabelGroups[groupIndex];
      }
      groupIndex++;
    }

    if (updatedKeys.contains(key)) {
      updatedKeys.remove(key);
      updatedGroups.remove(key);
    } else {
      updatedKeys.add(key);
      updatedGroups[key] = BoardCardLabelFilterGroupRequest(
        cardLabelUIds: _normalizeGroupIds(cardLabelUIds),
      );
    }

    emit(
      state.copyWith(
        selectedLabelGroupKeys: updatedKeys,
        selectedLabelGroups: updatedKeys
            .map((groupKey) => updatedGroups[groupKey])
            .whereType<BoardCardLabelFilterGroupRequest>()
            .toList(growable: false),
        selectedLabelIds: const {},
      ),
    );
  }

  void selectLabelGroups(Map<String, Iterable<String>> groups) {
    final keys = groups.keys.toSet();
    emit(
      state.copyWith(
        selectedLabelGroupKeys: keys,
        selectedLabelGroups: groups.values
            .map(
              (ids) => BoardCardLabelFilterGroupRequest(
                cardLabelUIds: _normalizeGroupIds(ids),
              ),
            )
            .toList(growable: false),
        selectedLabelIds: const {},
      ),
    );
  }

  void setCompletionFilter(BoardCompletionFilter filter) {
    if (state.completionFilter == filter) {
      emit(state.copyWith(clearCompletionFilter: true));
    } else {
      emit(state.copyWith(completionFilter: filter));
    }
  }

  void toggleDueDate(DueDateFilter filter) {
    final updated = Set<DueDateFilter>.from(state.dueDateFilters);
    updated.contains(filter) ? updated.remove(filter) : updated.add(filter);
    emit(state.copyWith(dueDateFilters: updated));
  }

  void toggleNoLabels() => emit(state.copyWith(noLabels: !state.noLabels));

  void setMatchMode(BoardFilterMatchMode mode) {
    emit(state.copyWith(matchMode: mode));
  }

  void clearAll() => emit(const BoardFilterState());

  static List<String> _normalizeGroupIds(Iterable<String> ids) {
    final normalized = <String>[];
    for (final id in ids) {
      final trimmed = id.trim();
      if (trimmed.isNotEmpty && !normalized.contains(trimmed)) {
        normalized.add(trimmed);
      }
    }
    return normalized;
  }
}
