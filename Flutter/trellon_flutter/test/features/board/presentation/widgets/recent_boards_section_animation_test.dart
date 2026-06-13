import 'package:apptreolon/features/board/domain/entities/board_entity.dart';
import 'package:apptreolon/features/board/presentation/widgets/board_list/recent_boards_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('uses animated size and switcher for paged content', (
    tester,
  ) async {
    final boards = List.generate(
      6,
      (index) => BoardEntity(
        id: 'board-$index',
        name: 'Board $index',
        visibility: 'Private',
        isPersonal: false,
        workspaceName: 'Workspace',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: RecentBoardsSection(
              boards: boards,
              title: 'Boards',
              emptyMessage: 'No boards',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedSize), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });
}
