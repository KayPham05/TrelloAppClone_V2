import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apptreolon/features/auth/domain/usecases/verify_code_usecase.dart';
import 'package:apptreolon/features/auth/presentation/cubit/verify_cubit.dart';

class MockVerifyCodeUseCase extends Mock implements VerifyCodeUseCase {}
class MockResendCodeUseCase extends Mock implements ResendCodeUseCase {}
class MockCheckOtpStatusUseCase extends Mock implements CheckOtpStatusUseCase {}

void main() {
  late VerifyCubit verifyCubit;
  late MockVerifyCodeUseCase mockVerifyCodeUseCase;
  late MockResendCodeUseCase mockResendCodeUseCase;
  late MockCheckOtpStatusUseCase mockCheckOtpStatusUseCase;

  setUp(() {
    mockVerifyCodeUseCase = MockVerifyCodeUseCase();
    mockResendCodeUseCase = MockResendCodeUseCase();
    mockCheckOtpStatusUseCase = MockCheckOtpStatusUseCase();
    
    verifyCubit = VerifyCubit(
      verifyCodeUseCase: mockVerifyCodeUseCase,
      resendCodeUseCase: mockResendCodeUseCase,
      checkOtpStatusUseCase: mockCheckOtpStatusUseCase,
    );
  });

  tearDown(() {
    verifyCubit.close();
  });

  test('checkOtpStatus starts countdown', () async {
    when(() => mockCheckOtpStatusUseCase(email: 'test@example.com'))
        .thenAnswer((_) async => 10);

    expectLater(
      verifyCubit.stream,
      emitsInOrder([
        isA<VerifyCountdown>().having((s) => s.seconds, 'seconds', 30),
        isA<VerifyCountdown>().having((s) => s.seconds, 'seconds', 10),
      ]),
    );

    await verifyCubit.checkOtpStatus('test@example.com');
  });

  test('checkOtpStatus starts 30s countdown on error', () async {
    when(() => mockCheckOtpStatusUseCase(email: 'test@example.com'))
        .thenThrow(Exception('error'));

    expectLater(
      verifyCubit.stream,
      emitsInOrder([
        isA<VerifyCountdown>().having((s) => s.seconds, 'seconds', 30),
        isA<VerifyCountdownDone>(),
      ]),
    );

    await verifyCubit.checkOtpStatus('test@example.com');
  });
}
