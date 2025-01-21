import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/helper/two.factor.auth.dart';

import '../helper.dart';

void main() {
  testUnit('should generate a secret of the specified length', () {
    const int length = 32;
    final String secret = TwoFactorAuthHelper.generateSecret();
    expect(secret.length, equals(length));
  });

  testUnit('should only contain allowed characters', () {
    final String secret = TwoFactorAuthHelper.generateSecret();
    const String allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    for (final char in secret.split('')) {
      expect(
        allowedChars.contains(char),
        isTrue,
        reason: 'Invalid character $char found.',
      );
    }
  });

  testUnit('should generate different secrets on multiple calls', () {
    final String secret1 = TwoFactorAuthHelper.generateSecret();
    final String secret2 = TwoFactorAuthHelper.generateSecret();
    expect(
      secret1,
      isNot(equals(secret2)),
      reason: 'Secrets should not be identical.',
    );
  });

  testUnit('should generate secrets of default length', () {
    final String secret = TwoFactorAuthHelper.generateSecret();
    expect(secret.length, equals(32));
  });
}
