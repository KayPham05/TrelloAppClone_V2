import 'package:apptreolon/features/auth/presentation/cubit/login_cubit.dart';
import 'package:apptreolon/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// Mock class for LoginCubit
class MockLoginCubit extends Mock implements LoginCubit {}

void main() {
  late MockLoginCubit mockLoginCubit;

  setUp(() {
    mockLoginCubit = MockLoginCubit();
    
    // Register the mock using GetIt
    final getIt = GetIt.instance;
    getIt.allowReassignment = true;
    getIt.registerSingleton<LoginCubit>(mockLoginCubit);

    // Setup initial state for mock
    when(() => mockLoginCubit.state).thenReturn(LoginInitial());
    when(() => mockLoginCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLoginCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('Login page displays all UI elements correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập vào Trello'), findsOneWidget);
    expect(find.text('Nhập địa chỉ email'), findsOneWidget);
    expect(find.text('Nhập mật khẩu'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });

  testWidgets('Show error messages when fields are empty and login button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap login button without entering anything
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump(); // No need for pumpAndSettle if no animation, but pump to trigger rebuild

    expect(find.text('Email không hợp lệ'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
  });

  testWidgets('Call login method on cubit when fields are valid', (WidgetTester tester) async {
    // Stub the login method
    when(() => mockLoginCubit.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async {});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Enter email and password
    await tester.enterText(find.widgetWithText(TextFormField, 'Nhập địa chỉ email'), 'test@gmail.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Nhập mật khẩu'), 'password123');

    // Tap login
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();

    // Verify cubit method was called
    verify(() => mockLoginCubit.login(email: 'test@gmail.com', password: 'password123')).called(1);
  });
}
