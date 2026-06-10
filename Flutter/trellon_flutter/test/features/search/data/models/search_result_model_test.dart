import 'package:flutter_test/flutter_test.dart';
import 'package:apptreolon/features/search/data/models/search_result_model.dart';

void main() {
  group('SearchBoardModel', () {
    test('should parse from valid JSON successfully', () {
      final json = {
        'boardUId': 'board-123',
        'boardName': 'Test Board',
        'backgroundUrl': 'https://example.com/bg.png',
      };

      final result = SearchBoardModel.fromJson(json);

      expect(result.boardUId, 'board-123');
      expect(result.boardName, 'Test Board');
      expect(result.backgroundUrl, 'https://example.com/bg.png');
    });

    test('should handle missing optional fields and nulls safely', () {
      final json = <String, dynamic>{
        'boardUId': null,
        'boardName': null,
        'backgroundUrl': null,
      };

      final result = SearchBoardModel.fromJson(json);

      expect(result.boardUId, '');
      expect(result.boardName, '');
      expect(result.backgroundUrl, isNull);
    });
  });

  group('SearchCardModel', () {
    test('should parse from valid JSON successfully', () {
      final json = {
        'cardUId': 'card-456',
        'title': 'Test Card',
        'boardName': 'Test Board',
        'boardUId': 'board-123',
      };

      final result = SearchCardModel.fromJson(json);

      expect(result.cardUId, 'card-456');
      expect(result.title, 'Test Card');
      expect(result.boardName, 'Test Board');
      expect(result.boardUId, 'board-123');
    });

    test('should handle missing optional fields and nulls safely', () {
      final json = <String, dynamic>{
        'cardUId': null,
        'title': null,
      };

      final result = SearchCardModel.fromJson(json);

      expect(result.cardUId, '');
      expect(result.title, '');
      expect(result.boardName, isNull);
      expect(result.boardUId, isNull);
    });
  });

  group('SearchResultModel', () {
    test('should parse from valid JSON containing boards and cards', () {
      final json = {
        'boards': [
          {
            'boardUId': 'b1',
            'boardName': 'Board 1',
          }
        ],
        'cards': [
          {
            'cardUId': 'c1',
            'title': 'Card 1',
          }
        ]
      };

      final result = SearchResultModel.fromJson(json);

      expect(result.boards.length, 1);
      expect(result.boards.first.boardUId, 'b1');
      expect(result.cards.length, 1);
      expect(result.cards.first.cardUId, 'c1');
    });

    test('should parse empty lists when boards and cards are missing or null', () {
      final json = <String, dynamic>{
        'boards': null,
        'cards': null,
      };

      final result = SearchResultModel.fromJson(json);

      expect(result.boards, isEmpty);
      expect(result.cards, isEmpty);
    });
  });
}
