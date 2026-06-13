import 'package:apptreolon/features/card/domain/entities/card_entity.dart';
import 'package:apptreolon/features/card/presentation/widgets/card_detail/mention_suggestion_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('detectActiveMentionToken', () {
    test('detects simple mention at cursor', () {
      final result = detectActiveMentionToken('hello @an', 9);

      expect(result?.query, 'an');
      expect(result?.start, 6);
      expect(result?.end, 9);
    });

    test('detects full email mention at cursor', () {
      final text = 'please @member+qa@example.com';
      final result = detectActiveMentionToken(text, text.length);

      expect(result?.query, 'member+qa@example.com');
    });

    test('returns null after whitespace closes mention', () {
      final text = 'hello @an ';
      final result = detectActiveMentionToken(text, text.length);

      expect(result, isNull);
    });

    test('uses mention nearest to cursor', () {
      final text = '@first hello @sec';
      final result = detectActiveMentionToken(text, text.length);

      expect(result?.query, 'sec');
      expect(result?.start, 13);
    });
  });

  group('filterMentionMembers', () {
    const members = [
      CardMemberEntity(
        id: '1',
        userUId: 'u1',
        userName: 'An Nguyen',
        email: 'an@example.com',
        role: 'Assignee',
      ),
      CardMemberEntity(
        id: '2',
        userUId: 'u2',
        userName: 'QA Member',
        email: 'member+qa@example.com',
        role: 'Assignee',
      ),
    ];

    test('matches by username, email prefix, and full email', () {
      expect(filterMentionMembers(members, 'an'), [members[0]]);
      expect(filterMentionMembers(members, 'member+qa'), [members[1]]);
      expect(filterMentionMembers(members, 'member+qa@example.com'), [
        members[1],
      ]);
    });
  });
}
