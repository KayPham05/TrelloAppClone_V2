import '../../domain/entities/report_history_item_entity.dart';
import '../../domain/entities/report_history_page_entity.dart';

class ReportHistoryItemModel extends ReportHistoryItemEntity {
  const ReportHistoryItemModel({
    required super.reportUId,
    required super.scopeType,
    required super.scopeUId,
    required super.title,
    required super.overallProgress,
    required super.model,
    super.generatedAt,
  });

  factory ReportHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return ReportHistoryItemModel(
      reportUId: _string(json['reportUId']),
      scopeType: _string(json['scopeType']),
      scopeUId: _string(json['scopeUId']),
      title: _string(json['title']),
      overallProgress: _int(json['overallProgress']).clamp(0, 100).toInt(),
      model: _firstString(json, ['model', 'modelUsed']),
      generatedAt: _date(json['generatedAt']),
    );
  }

  ReportHistoryItemEntity toEntity() => this;
}

class ReportHistoryPageModel extends ReportHistoryPageEntity {
  const ReportHistoryPageModel({
    required super.items,
    required super.totalCount,
    required super.page,
    required super.pageSize,
    required super.hasMore,
  });

  factory ReportHistoryPageModel.fromJson(Map<String, dynamic> json) {
    return ReportHistoryPageModel(
      items: _list(
        json['items'],
      ).map((item) => ReportHistoryItemModel.fromJson(item)).toList(),
      totalCount: _int(json['totalCount']),
      page: _int(json['page']),
      pageSize: _int(json['pageSize']),
      hasMore: json['hasMore'] == true,
    );
  }

  ReportHistoryPageEntity toEntity() => this;
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _string(Object? value) => value?.toString() ?? '';

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
  }
  return '';
}

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
