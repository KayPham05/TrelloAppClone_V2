import 'package:apptreolon/features/board/data/models/board_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BoardModel reads and writes isStarred', () {
    final board = BoardModel.fromJson({
      'boardUId': 'board-1',
      'boardName': 'Roadmap',
      'visibility': 'Private',
      'isPersonal': false,
      'workspaceUId': 'workspace-1',
      'workspaceName': 'Team',
      'status': 'Active',
      'isStarred': true,
    });

    expect(board.isStarred, isTrue);
    expect(board.toJson()['isStarred'], isTrue);
  });
}
