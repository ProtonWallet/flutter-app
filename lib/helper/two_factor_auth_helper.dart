import 'dart:math';

class TwoFactorAuthHelper {
  static String generateSecret({int length = 32}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final Random random = Random.secure();
    final List<int> secretCodeUnits = List.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    );
    return String.fromCharCodes(secretCodeUnits);
  }
}
