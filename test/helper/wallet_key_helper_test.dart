import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
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
  });
}
