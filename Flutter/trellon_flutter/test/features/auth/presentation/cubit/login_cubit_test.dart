import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/features/auth/domain/usecases/login_usecase.dart';
import 'package:apptreolon/features/auth/presentation/cubit/login_cubit.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late LoginCubit loginCubit;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    loginCubit = LoginCubit(loginUseCase: mockLoginUseCase);
  });

  tearDown(() {
    loginCubit.close();
  });

  test('emits LoginAccountLocked when Exception contains ACCOUNT_LOCKED', () async {
    when(() => mockLoginUseCase(email: 'test@example.com', password: 'password'))
        .thenThrow(Exception('ACCOUNT_LOCKED|test@example.com'));

    expectLater(
      loginCubit.stream,
      emitsInOrder([
        isA<LoginLoading>(),
        isA<LoginAccountLocked>().having((s) => s.email, 'email', 'test@example.com'),
      ]),
    );

    await loginCubit.login(email: 'test@example.com', password: 'password');
  });
}
