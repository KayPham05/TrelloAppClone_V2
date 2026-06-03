import 'package:flutter_test/flutter_test.dart';
import 'package:apptreolon/routes.dart';

void main() {
  test('AppRoutes contains lockedAccount route', () {
    expect(AppRoutes.lockedAccount, '/locked-account');
    expect(AppRoutes.routes.containsKey(AppRoutes.lockedAccount), isTrue);
  });
}
