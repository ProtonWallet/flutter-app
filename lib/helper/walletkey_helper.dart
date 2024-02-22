import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class WalletKeyHelper {
  static SecretKey generateSecretKey() {
    SecretKey secretKey = SecretKey(getRandomValues(32));
    return secretKey;
  }

  static Uint8List mockKeysEntropy() {
    return Uint8List.fromList([
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
    ]);
  }

  static List<int> mockIV(){
    return [138, 168, 89, 85, 141, 143, 120, 250, 36, 179, 21, 3];
  }

  static Uint8List getRandomValues(int length) {
    Random random = Random();
    List<int> bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return Uint8List.fromList(bytes);
  }

  static Future<String> secretKeyAsString(SecretKey secretKey) async {
    return String.fromCharCodes(await secretKey.extractBytes());
  }

  static restoreSecretKeyFromString(String secretKeyStr) {
    return SecretKey(secretKeyStr.codeUnits);
  }

  static restoreSecretKeyFromEntropy(Uint8List entropy) {
    return SecretKey(entropy);
  }

  static Future<String> encrypt(SecretKey secretKey, String plaintext, {List<int>? initIV}) async {
    Uint8List bytes = utf8.encode(plaintext); // for UTF-8 Strings
    List<int> iv = AesGcm.with256bits().newNonce();
    if (initIV != null){
      iv = initIV;
    }
    SecretBox secretBox = await AesGcm.with256bits()
        .encrypt(bytes, nonce: iv, secretKey: secretKey);
    String encryptText = base64Encode(secretBox.concatenation()); // Base64 encoding of: IV | ciphertext | MAC
    return encryptText;
  }

  static Future<String> decrypt(SecretKey secretKey, String encryptText) async {
    Uint8List bytes = base64Decode(encryptText);
    Uint8List iv = bytes.sublist(0, 12);
    Uint8List ciphertext = bytes.sublist(12, bytes.length - 16);
    Uint8List mac = bytes.sublist(bytes.length - 16);
    SecretBox secretBox = SecretBox(ciphertext, nonce: iv, mac: Mac(mac));
    List<int> decrypted =
        await AesGcm.with256bits().decrypt(secretBox, secretKey: secretKey);
    String plaintext = utf8.decode(decrypted);
    return plaintext;
  }
}
