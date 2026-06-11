import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:apptreolon/features/auth/data/repositories/auth_repository_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late AuthRepositoryImpl authRepository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    authRepository = AuthRepositoryImpl(mockDio);
  });

  test('login throws ACCOUNT_LOCKED exception when account is locked', () async {
    registerFallbackValue(Options());
    when(() => mockDio.post(
      any(),
      data: any(named: 'data'),
      queryParameters: any(named: 'queryParameters'),
      options: any(named: 'options'),
      cancelToken: any(named: 'cancelToken'),
      onSendProgress: any(named: 'onSendProgress'),
      onReceiveProgress: any(named: 'onReceiveProgress'),
    )).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: {
          'requiresVerification': true,
          'message': 'Tài khoản đã bị khóa',
          'email': 'locked@example.com',
        },
      ),
    );

    expect(
      () => authRepository.login(email: 'locked@example.com', password: 'password'),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('ACCOUNT_LOCKED|locked@example.com'))),
    );
  });
}
