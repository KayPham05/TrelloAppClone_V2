import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptreolon/init_dependencies.dart';
import 'package:apptreolon/features/profile/presentation/pages/information_page.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    SharedPreferences.setMockInitialValues({
      'user_name': 'Test User',
      'user_email': 'test@example.com',
    });
    if (serviceLocator.isRegistered<Dio>()) {
      serviceLocator.unregister<Dio>();
    }
    serviceLocator.registerSingleton<Dio>(mockDio);
  });

  tearDown(() {
    serviceLocator.reset();
  });

  testWidgets('InformationPage renders user data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InformationPage(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Thông tin cá nhân'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });
}
