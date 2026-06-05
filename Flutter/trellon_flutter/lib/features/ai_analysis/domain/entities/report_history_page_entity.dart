import 'package:equatable/equatable.dart';

import 'report_history_item_entity.dart';

class ReportHistoryPageEntity extends Equatable {
  final List<ReportHistoryItemEntity> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;

  const ReportHistoryPageEntity({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [items, totalCount, page, pageSize, hasMore];
}
