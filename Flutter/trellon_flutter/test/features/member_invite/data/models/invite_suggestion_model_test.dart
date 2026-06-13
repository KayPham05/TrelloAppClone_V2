import 'package:flutter_test/flutter_test.dart';
import 'package:apptreolon/features/member_invite/data/models/invite_suggestion_model.dart';

void main() {
  test('InviteSuggestionModel parses backend response', () {
    final model = InviteSuggestionModel.fromJson({
      'userUId': 'user-1',
      'userName': 'Nguyen Van A',
      'email': 'nguyena@example.com',
      'avatarUrl': 'https://example.com/a.png',
      'workspaceRole': 'Member',
    });

    expect(model.userUId, 'user-1');
    expect(model.userName, 'Nguyen Van A');
    expect(model.email, 'nguyena@example.com');
    expect(model.avatarUrl, 'https://example.com/a.png');
    expect(model.workspaceRole, 'Member');
  });
}
