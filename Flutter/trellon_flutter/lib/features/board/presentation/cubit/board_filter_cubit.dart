import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/list_entity.dart';
import '../../../card/domain/entities/card_entity.dart';

// ── Due-date quick filters ───────────────────────────────────────────────────
enum DueDateFilter { none, overdue, today, thisWeek, thisMonth }

extension DueDateFilterLabel on DueDateFilter {
  String get label {
    switch (this) {
      case DueDateFilter.none:
        return '';
      case DueDateFilter.overdue:
        return 'Quá hạn';
      case DueDateFilter.today:
        return 'Hết hạn hôm nay';
      case DueDateFilter.thisWeek:
        return 'Hết hạn trong tuần';
      case DueDateFilter.thisMonth:
        return 'Hết hạn trong tháng';
    }
  }
}

// ── State ────────────────────────────────────────────────────────────────────
class BoardFilterState extends Equatable {
  final String query;
  final Set<String> selectedMemberUIds; // userUId
  final Set<String> selectedLabelIds; // label id
  final DueDateFilter dueDateFilter;

  const BoardFilterState({
    this.query = '',
    this.selectedMemberUIds = const {},
    this.selectedLabelIds = const {},
    this.dueDateFilter = DueDateFilter.none,
  });

  bool get isActive =>
      query.isNotEmpty ||
      selectedMemberUIds.isNotEmpty ||
      selectedLabelIds.isNotEmpty ||
      dueDateFilter != DueDateFilter.none;

  BoardFilterState copyWith({
    String? query,
    Set<String>? selectedMemberUIds,
    Set<String>? selectedLabelIds,
    DueDateFilter? dueDateFilter,
  }) {
    return BoardFilterState(
      query: query ?? this.query,
      selectedMemberUIds: selectedMemberUIds ?? this.selectedMemberUIds,
      selectedLabelIds: selectedLabelIds ?? this.selectedLabelIds,
      dueDateFilter: dueDateFilter ?? this.dueDateFilter,
    );
  }

  @override
  List<Object?> get props => [
    query,
    selectedMemberUIds,
    selectedLabelIds,
    dueDateFilter,
  ];
}

// ── Cubit ────────────────────────────────────────────────────────────────────
class BoardFilterCubit extends Cubit<BoardFilterState> {
  BoardFilterCubit() : super(const BoardFilterState());

  void setQuery(String q) => emit(state.copyWith(query: q));

  void toggleMember(String userUId) {
    final updated = Set<String>.from(state.selectedMemberUIds);
    if (updated.contains(userUId)) {
      updated.remove(userUId);
    } else {
      updated.add(userUId);
    }
    emit(state.copyWith(selectedMemberUIds: updated));
  }

  void toggleLabel(String labelId) {
    final updated = Set<String>.from(state.selectedLabelIds);
    if (updated.contains(labelId)) {
      updated.remove(labelId);
    } else {
      updated.add(labelId);
    }
    emit(state.copyWith(selectedLabelIds: updated));
  }

  void setDueDate(DueDateFilter filter) {
    final next = state.dueDateFilter == filter ? DueDateFilter.none : filter;
    emit(state.copyWith(dueDateFilter: next));
  }

  void clearAll() => emit(const BoardFilterState());

  // ── Core filter logic ──────────────────────────────────────────────────────
  /// Returns a copy of [lists] with only matching cards.
  /// Lists that end up empty are retained (so columns still show).
  List<ListEntity> applyFilter(List<ListEntity> lists) {
    if (!state.isActive) return lists;

    return lists.map((list) {
      final filteredCards = list.cards
          .where((card) => _cardMatches(card, list))
          .toList();
      return list.copyWith(cards: filteredCards);
    }).toList();
  }

  /// Total matching cards count across all lists
  int countMatches(List<ListEntity> lists) {
    if (!state.isActive) return lists.fold(0, (sum, l) => sum + l.cards.length);
    return lists.fold(
      0,
      (sum, l) => sum + l.cards.where((c) => _cardMatches(c, l)).length,
    );
  }

  bool _cardMatches(CardEntity card, ListEntity list) {
    if (!_matchesQuery(card, list)) return false;
    if (!_matchesMembers(card)) return false;
    if (!_matchesLabels(card)) return false;
    if (!_matchesDueDate(card)) return false;
    return true;
  }

  bool _matchesQuery(CardEntity card, ListEntity list) {
    if (state.query.isEmpty) return true;
    final q = state.query.toLowerCase();
    
    if (card.title.toLowerCase().contains(q)) return true;
    if ((card.description ?? '').toLowerCase().contains(q)) return true;
    if (list.name.toLowerCase().contains(q)) return true;
    if (card.todoItems.any((t) => t.title.toLowerCase().contains(q))) return true;
    if (card.labels.any((l) => l.title.toLowerCase().contains(q))) return true;
    if (card.members.any((m) => m.userName.toLowerCase().contains(q))) return true;
    
    return false;
  }

  bool _matchesMembers(CardEntity card) {
    if (state.selectedMemberUIds.isEmpty) return true;
    final cardMemberIds = card.members.map((m) => m.userUId).toSet();
    return state.selectedMemberUIds.every((id) => cardMemberIds.contains(id));
  }

  bool _matchesLabels(CardEntity card) {
    if (state.selectedLabelIds.isEmpty) return true;
    final cardLabelIds = card.labels.map((l) => l.id).toSet();
    return state.selectedLabelIds.any((id) => cardLabelIds.contains(id));
  }

  bool _matchesDueDate(CardEntity card) {
    if (state.dueDateFilter == DueDateFilter.none) return true;
    
    final due = card.dueDate;
    if (due == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);

    switch (state.dueDateFilter) {
      case DueDateFilter.overdue:
        return dueDay.isBefore(today);
      case DueDateFilter.today:
        return dueDay == today;
      case DueDateFilter.thisWeek:
        final endOfWeek = today.add(Duration(days: 7 - today.weekday));
        return !dueDay.isBefore(today) && !dueDay.isAfter(endOfWeek);
      case DueDateFilter.thisMonth:
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        return !dueDay.isBefore(today) && !dueDay.isAfter(endOfMonth);
      case DueDateFilter.none:
        return true;
    }
  }
}
