class BoardFilterRawLabel {
  final String id;
  final String title;
  final String colorCode;

  const BoardFilterRawLabel({
    required this.id,
    required this.title,
    required this.colorCode,
  });
}

class BoardFilterLabelOption {
  final String key;
  final String title;
  final String colorCode;
  final List<String> cardLabelUIds;

  const BoardFilterLabelOption({
    required this.key,
    required this.title,
    required this.colorCode,
    required this.cardLabelUIds,
  });

  bool matchesQuery(String query) {
    final needle = BoardFilterLabelGrouper.normalizeSearch(query);
    return needle.isEmpty ||
        BoardFilterLabelGrouper.normalizeSearch(title).contains(needle);
  }
}

class BoardFilterLabelGrouper {
  static List<BoardFilterLabelOption> group(
    Iterable<BoardFilterRawLabel> labels,
  ) {
    final groups = <String, BoardFilterLabelOption>{};
    for (final label in labels) {
      final title = label.title.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (title.isEmpty) continue;

      final colorCode = normalizeColorCode(label.colorCode);
      final key = '${normalizeTitle(title)}|$colorCode';
      final existing = groups[key];
      if (existing == null) {
        groups[key] = BoardFilterLabelOption(
          key: key,
          title: title,
          colorCode: colorCode,
          cardLabelUIds: [label.id],
        );
      } else if (!existing.cardLabelUIds.contains(label.id)) {
        existing.cardLabelUIds.add(label.id);
      }
    }

    final options = groups.values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    return options;
  }

  static String normalizeTitle(String value) {
    final collapsed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return stripVietnameseMarks(collapsed).toLowerCase();
  }

  static String normalizeSearch(String value) {
    return stripVietnameseMarks(value).trim().toLowerCase();
  }

  static String normalizeColorCode(String value) {
    return value.trim().toUpperCase();
  }

  static String stripVietnameseMarks(String value) {
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
