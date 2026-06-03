import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:apptreolon/features/profile/presentation/widgets/profile_text_field_widget.dart';

void main() {
  testWidgets('ProfileTextFieldWidget renders correctly', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileTextFieldWidget(
            label: 'Test Label',
            controller: controller,
            hintText: 'Test Hint',
            icon: Icons.person,
          ),
        ),
      ),
    );

    expect(find.text('Test Label'), findsOneWidget);
    expect(find.text('Test Hint'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
