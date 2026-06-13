import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apptreolon/features/member_invite/domain/entities/invite_batch_result.dart';
import 'package:apptreolon/features/member_invite/domain/entities/invite_suggestion.dart';
import 'package:apptreolon/features/member_invite/presentation/widgets/member_invite_picker.dart';

void main() {
  testWidgets('selects suggestions as chips and submits selected users', (
    tester,
  ) async {
    final submitted = <InviteSuggestion>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberInvitePicker(
            title: 'Invite members',
            debounceDuration: MemberInvitePicker.defaultDebounceDuration,
            searchSuggestions:
                ({
                  required String query,
                  required List<InviteSuggestion> selected,
                }) async {
                  return const [
                    InviteSuggestion(
                      userUId: 'user-1',
                      userName: 'Nguyen Van A',
                      email: 'nguyena@example.com',
                    ),
                  ];
                },
            onSubmit: (selected) async {
              submitted.addAll(selected);
              return const InviteBatchResult(successCount: 1, failureCount: 0);
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'nguyen');
    await tester.pump(MemberInvitePicker.defaultDebounceDuration);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.text('Nguyen Van A'), findsOneWidget);

    await tester.tap(find.text('Mời'));
    await tester.pumpAndSettle();

    expect(submitted.single.userUId, 'user-1');
  });

  testWidgets('shows loading state and removes selected chips smoothly', (
    tester,
  ) async {
    final completer = Completer<List<InviteSuggestion>>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberInvitePicker(
            title: 'Invite members',
            debounceDuration: MemberInvitePicker.defaultDebounceDuration,
            searchSuggestions:
                ({
                  required String query,
                  required List<InviteSuggestion> selected,
                }) async {
                  return completer.future;
                },
            onSubmit: (selected) async {
              return const InviteBatchResult(successCount: 1, failureCount: 0);
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'nguyen');
    await tester.pump(MemberInvitePicker.defaultDebounceDuration);
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    completer.complete(const [
      InviteSuggestion(
        userUId: 'user-1',
        userName: 'Nguyen Van A',
        email: 'nguyena@example.com',
      ),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.byType(InputChip), findsOneWidget);

    tester.widget<InputChip>(find.byType(InputChip)).onDeleted?.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pumpAndSettle();

    expect(find.byType(InputChip), findsNothing);
  });
}
