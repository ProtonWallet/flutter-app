import 'dart:convert';
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
      SecretKey secretKeyOrg = WalletKeyHelper.generateSecretKey();
      String secretKeyStr =
          await WalletKeyHelper.secretKeyAsString(secretKeyOrg);
      String plainText = "Hello world";
      String encryptText = base64Encode(
          utf8.encode(await WalletKeyHelper.encrypt(secretKeyOrg, plainText)));

      SecretKey secretKeyNew =
          WalletKeyHelper.restoreSecretKeyFromString(secretKeyStr);
      String decryptText = await WalletKeyHelper.decrypt(
          secretKeyNew, utf8.decode(base64Decode(encryptText)));
      expect(decryptText, equals(plainText));
    });

    test('restore walletKey and decrypt', () async {
      String plainText = "Hello AES-256-GCM";
      String encryptText =
          "dTb2Z1bsWkpo2TTCWOK09tanO3n5Ipepbj5WlCRZSuvlkEAxfePeUBCu4Qo6";
      SecretKey secretKey = WalletKeyHelper.restoreSecretKeyFromString(
          "2b48dff46c3a7f2bd661e5a379ca40dd");
      String decryptText =
          await WalletKeyHelper.decrypt(secretKey, encryptText);
      expect(decryptText, equals(plainText));
    });

    test('restore walletKey and encrypt', () async {
      String plaintext = "benefit indoor helmet wine exist height grain spot rely half beef nothing";
      String encryptText =
          "iqhZVY2PePoksxUDO5H8HT8FroYZ31DauI6SgfXtHao1s4OU5N45LWO29odlCt21Rvr7I30jsW3zweZcernm9Fsb0xH4KcP3YFarPTDm7C57WRJRRoT+28HKmtcWs5jTPPzMsUk=";
      SecretKey secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(Uint8List.fromList([
        239, 203, 93, 93, 253, 145, 50, 82, 227, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160, 29, 164, 144, 177, 101, 205, 128, 169, 38, 59, 33, 146, 218
      ]));

      String encryptText2 = await WalletKeyHelper.encrypt(secretKey, plaintext, initIV: WalletKeyHelper.mockIV());
      expect(encryptText2, equals(encryptText));
    });

    test('restore walletKey and decrypt', () async {
      String plaintext = "benefit indoor helmet wine exist height grain spot rely half beef nothing";
      String encryptText =
          "iqhZVY2PePoksxUDO5H8HT8FroYZ31DauI6SgfXtHao1s4OU5N45LWO29odlCt21Rvr7I30jsW3zweZcernm9Fsb0xH4KcP3YFarPTDm7C57WRJRRoT+28HKmtcWs5jTPPzMsUk=";
      SecretKey secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(Uint8List.fromList([
        239, 203, 93, 93, 253, 145, 50, 82, 227, 145, 154, 177, 206, 86, 83, 32, 251, 160, 160, 29, 164, 144, 177, 101, 205, 128, 169, 38, 59, 33, 146, 218
      ]));

      String decryptText =
      await WalletKeyHelper.decrypt(secretKey, encryptText);
      expect(decryptText, equals(plaintext));
    });
  });
}
