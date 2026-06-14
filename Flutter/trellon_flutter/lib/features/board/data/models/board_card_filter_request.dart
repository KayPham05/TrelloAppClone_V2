class BoardCardFilterRequest {
  final String keyword;
  final bool noMembers;
  final bool assignedToMe;
  final Set<String> memberUIds;
  final String? completionStatus;
  final Set<String> dueDateFilters;
  final bool noLabels;
  final Set<String> labelUIds;
  final List<BoardCardLabelFilterGroupRequest> selectedLabelGroups;
  final String matchMode;

  const BoardCardFilterRequest({
    this.keyword = '',
    this.noMembers = false,
    this.assignedToMe = false,
    this.memberUIds = const {},
    this.completionStatus,
    this.dueDateFilters = const {},
    this.noLabels = false,
    this.labelUIds = const {},
    this.selectedLabelGroups = const [],
    this.matchMode = 'exact',
  });

  bool get isActive =>
      keyword.trim().isNotEmpty ||
      noMembers ||
      assignedToMe ||
      memberUIds.isNotEmpty ||
      completionStatus != null ||
      dueDateFilters.isNotEmpty ||
      noLabels ||
      labelUIds.isNotEmpty ||
      selectedLabelGroups.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword.trim(),
      'noMembers': noMembers,
      'assignedToMe': assignedToMe,
      'memberUIds': memberUIds.toList(),
      'completionStatus': completionStatus,
      'dueDateFilters': dueDateFilters.toList(),
      'noLabels': noLabels,
      'labelUIds': labelUIds.toList(),
      'selectedLabelGroups': selectedLabelGroups
          .map((group) => group.toJson())
          .toList(growable: false),
      'matchMode': matchMode,
    };
  }
}

class BoardCardLabelFilterGroupRequest {
  final List<String> cardLabelUIds;

  const BoardCardLabelFilterGroupRequest({required this.cardLabelUIds});

  Map<String, dynamic> toJson() {
    return {'cardLabelUIds': cardLabelUIds};
  }

  @override
  bool operator ==(Object other) {
    return other is BoardCardLabelFilterGroupRequest &&
        _listEquals(cardLabelUIds, other.cardLabelUIds);
  }

  @override
  int get hashCode => Object.hashAll(cardLabelUIds);

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
