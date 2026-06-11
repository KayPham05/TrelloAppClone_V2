import 'package:flutter/material.dart';

class CardStatusValues {
  static const String completed = 'completed';
  static const String toDo = 'to_do';
  static const String dueSoon = 'due_soon';
  static const String overdue = 'overdue';

  static const String dueDateInPastMessage =
      'Ngày hết hạn không được trong quá khứ';
  static const String startDateAfterDueDateMessage =
      'Ngày bắt đầu không được lớn hơn ngày hết hạn';

  static const Map<String, String> _legacyStatusMap = {
    'hoàn thành': completed,
    'hoan thanh': completed,
    'done': completed,
    'completed': completed,
    'complete': completed,
    'to do': toDo,
    'todo': toDo,
    'to_do': toDo,
    'due_soon': dueSoon,
    'duesoon': dueSoon,
    'due soon': dueSoon,
    'sắp hết hạn': dueSoon,
    'sap het han': dueSoon,
    'overdue': overdue,
    'over due': overdue,
    'hết hạn': overdue,
    'het han': overdue,
  };

  static String normalize(String? status) {
    final key = status?.trim().toLowerCase();
    if (key == null || key.isEmpty) return toDo;
    return _legacyStatusMap[key] ?? toDo;
  }

  static bool isCompleted(String? status) => normalize(status) == completed;
  static bool isOverdue(String? status) => normalize(status) == overdue;
  static bool isDueSoon(String? status) => normalize(status) == dueSoon;

  static String calculate(String? currentStatus, DateTime? dueDate) {
    if (isCompleted(currentStatus)) return completed;
    if (dueDate == null) return toDo;

    final now = DateTime.now().toUtc();
    final dueUtc = dueDate.toUtc();
    if (dueUtc.isBefore(now)) return overdue;
    return dueUtc.difference(now) <= const Duration(days: 1) ? dueSoon : toDo;
  }

  static bool isDueDateInPast(DateTime? dueDate) {
    return dueDate != null && dueDate.toUtc().isBefore(DateTime.now().toUtc());
  }

  static String label(String? status) {
    switch (normalize(status)) {
      case completed:
        return 'Hoàn thành';
      case overdue:
        return 'Hết hạn';
      case dueSoon:
        return 'Sắp hết hạn';
      default:
        return 'Phải làm';
    }
  }

  static Color color(String? status, {Color defaultColor = Colors.transparent}) {
    switch (normalize(status)) {
      case overdue:
        return Colors.red;
      case dueSoon:
        return Colors.amber;
      case completed:
        return Colors.green;
      default:
        return defaultColor;
    }
  }
}
