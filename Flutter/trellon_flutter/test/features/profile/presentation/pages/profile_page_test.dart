import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apptreolon/init_dependencies.dart';
import 'package:apptreolon/features/profile/presentation/pages/profile_page.dart';
import 'package:apptreolon/features/workspace/presentation/cubit/workspace_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockDio extends Mock implements Dio {}
class MockWorkspaceCubit extends Mock implements WorkspaceCubit {}

void main() {
  late MockDio mockDio;
  late MockWorkspaceCubit mockWorkspaceCubit;

  setUp(() {
    mockDio = MockDio();
    mockWorkspaceCubit = MockWorkspaceCubit();
    when(() => mockWorkspaceCubit.state).thenReturn(WorkspaceInitial());
    when(() => mockWorkspaceCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockWorkspaceCubit.close()).thenAnswer((_) async {});
    
    SharedPreferences.setMockInitialValues({
      'user_name': 'Profile User',
      'user_email': 'profile@example.com',
    });
    
    if (serviceLocator.isRegistered<Dio>()) {
      serviceLocator.unregister<Dio>();
    }
    serviceLocator.registerSingleton<Dio>(mockDio);
  });

  tearDown(() {
    serviceLocator.reset();
  });

  testWidgets('ProfilePage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<WorkspaceCubit>.value(
          value: mockWorkspaceCubit,
          child: const ProfilePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profile User'), findsOneWidget);
    expect(find.text('profile@example.com'), findsOneWidget);
    expect(find.text('CÀI ĐẶT TÀI KHOẢN'), findsOneWidget);
  });
}
