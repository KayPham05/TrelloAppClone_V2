import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptreolon/init_dependencies.dart';
import 'package:apptreolon/features/profile/presentation/pages/change_email_page.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    SharedPreferences.setMockInitialValues({});
    if (serviceLocator.isRegistered<Dio>()) {
      serviceLocator.unregister<Dio>();
    }
    serviceLocator.registerSingleton<Dio>(mockDio);
  });

  tearDown(() {
    serviceLocator.reset();
  });

  testWidgets('ChangeEmailPage renders and shows inputs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChangeEmailPage(),
      ),
    );

    expect(find.text('Đổi Email Liên Kết'), findsOneWidget);
    expect(find.text('Email mới'), findsOneWidget);
    expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
    expect(find.text('Tiếp tục'), findsOneWidget);
  });
}
