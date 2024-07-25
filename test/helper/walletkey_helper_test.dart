import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/helper/walletkey_helper.dart';

void main() {
  if (Platform.isLinux) {
    return;
  }
  group('WalletKeyHelper', () {
    test('generate and restore walletKey', () async {
      final SecretKey secretKeyOrg = WalletKeyHelper.generateSecretKey();
      final String encodedEntropy =
          await WalletKeyHelper.getEncodedEntropy(secretKeyOrg);
      const String plainText = "Hello world";
      final String encryptText =
          await WalletKeyHelper.encrypt(secretKeyOrg, plainText);

      final SecretKey secretKeyNew =
          WalletKeyHelper.restoreSecretKeyFromEncodedEntropy(encodedEntropy);
      final String decryptText =
          await WalletKeyHelper.decrypt(secretKeyNew, encryptText);
      expect(decryptText, equals(plainText));
    });

    test('restore walletKey and decrypt', () async {
      const String plainText = "Hello AES-256-GCM";
      const String encryptText =
          "dTb2Z1bsWkpo2TTCWOK09tanO3n5Ipepbj5WlCRZSuvlkEAxfePeUBCu4Qo6";
      final SecretKey secretKey =
          WalletKeyHelper.restoreSecretKeyFromEncodedEntropy(
              "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=");
      final String decryptText =
          await WalletKeyHelper.decrypt(secretKey, encryptText);
      expect(decryptText, equals(plainText));
    });

    test('restore walletKey and encrypt', () async {
      const String plaintext =
          "benefit indoor helmet wine exist height grain spot rely half beef nothing";
      const String encryptText =
          "iqhZVY2PePoksxUDO5H8HT8FroYZ31DauI6SgfXtHao1s4OU5N45LWO29odlCt21Rvr7I30jsW3zweZcernm9Fsb0xH4KcP3YFarPTDm7C57WRJRRoT+28HKmtcWs5jTPPzMsUk=";
      final SecretKey secretKey =
          WalletKeyHelper.restoreSecretKeyFromEntropy(Uint8List.fromList([
        239,
        203,
        93,
        93,
        253,
        145,
        50,
        82,
        227,
        145,
        154,
        177,
        206,
        86,
        83,
        32,
        251,
        160,
        160,
        29,
        164,
        144,
        177,
        101,
        205,
        128,
        169,
        38,
        59,
        33,
        146,
        218
      ]));

      final String encryptText2 = await WalletKeyHelper.encrypt(
          secretKey, plaintext,
          initIV: [138, 168, 89, 85, 141, 143, 120, 250, 36, 179, 21, 3]);
      expect(encryptText2, equals(encryptText));

      final String decryptText =
          await WalletKeyHelper.decrypt(secretKey, encryptText);
      expect(decryptText, equals(plaintext));
    });

    test('compare Random and Random secure', () async {
      final left = WalletKeyHelper.getRandomValues(32);
      final right = WalletKeyHelper.getSecureRandom(32);
      expect(left.length, right.length);
      const plaintext = "WalletKeyHelper.getSecureRandom(32);";
      final secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(right);
      final encrypted = await WalletKeyHelper.encrypt(secretKey, plaintext);
      final clearText = await WalletKeyHelper.decrypt(secretKey, encrypted);
      expect(plaintext, clearText);
    });
  });
}
