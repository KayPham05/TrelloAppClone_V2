import 'package:apptreolon/features/board/data/models/board_card_filter_request.dart';
import 'package:apptreolon/features/board/presentation/models/board_filter_label_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups labels by normalized title and color and keeps all ids', () {
    final options = BoardFilterLabelGrouper.group(const [
      BoardFilterRawLabel(
        id: 'A1',
        title: 'Đang thực hiện',
        colorCode: '#1e7f51',
      ),
      BoardFilterRawLabel(
        id: 'A2',
        title: '  Dang   thuc hien  ',
        colorCode: '#1E7F51',
      ),
      BoardFilterRawLabel(
        id: 'B1',
        title: 'Cần thực hiện',
        colorCode: '#FF9900',
      ),
    ]);

    expect(options, hasLength(2));
    final active = options.firstWhere(
      (option) => option.key == 'dang thuc hien|#1E7F51',
    );
    expect(active.cardLabelUIds, ['A1', 'A2']);
  });

  test('keeps same title with different colors as separate groups', () {
    final options = BoardFilterLabelGrouper.group(const [
      BoardFilterRawLabel(
        id: 'A1',
        title: 'Đang thực hiện',
        colorCode: '#1E7F51',
      ),
      BoardFilterRawLabel(
        id: 'A2',
        title: 'Đang thực hiện',
        colorCode: '#FF9900',
      ),
    ]);

    expect(options, hasLength(2));
  });

  test('keeps different titles with same color as separate groups', () {
    final options = BoardFilterLabelGrouper.group(const [
      BoardFilterRawLabel(
        id: 'A1',
        title: 'Đang thực hiện',
        colorCode: '#1E7F51',
      ),
      BoardFilterRawLabel(
        id: 'B1',
        title: 'Cần thực hiện',
        colorCode: '#1E7F51',
      ),
    ]);

    expect(options, hasLength(2));
  });

  test('search runs on grouped options and empty titles are hidden', () {
    final options = BoardFilterLabelGrouper.group(const [
      BoardFilterRawLabel(
        id: 'A1',
        title: 'Đang thực hiện',
        colorCode: '#1E7F51',
      ),
      BoardFilterRawLabel(
        id: 'A2',
        title: 'Dang thuc hien',
        colorCode: '#1E7F51',
      ),
      BoardFilterRawLabel(id: 'empty', title: '   ', colorCode: '#000000'),
    ]);

    expect(
      options.where((option) => option.matchesQuery('dang')),
      hasLength(1),
    );
    expect(
      options.any((option) => option.cardLabelUIds.contains('empty')),
      isFalse,
    );
  });

  test('request json sends label groups without dropping equivalent ids', () {
    const request = BoardCardFilterRequest(
      selectedLabelGroups: [
        BoardCardLabelFilterGroupRequest(cardLabelUIds: ['A1', 'A2']),
        BoardCardLabelFilterGroupRequest(cardLabelUIds: ['B1']),
      ],
      matchMode: 'any',
    );

    expect(request.toJson()['selectedLabelGroups'], [
      {
        'cardLabelUIds': ['A1', 'A2'],
      },
      {
        'cardLabelUIds': ['B1'],
      },
    ]);
    expect(request.toJson()['labelUIds'], isEmpty);
  });
}
