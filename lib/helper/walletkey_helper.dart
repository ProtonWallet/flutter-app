import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class WalletKeyHelper {
  static SecretKey generateSecretKey() {
    SecretKey secretKey = SecretKey(getRandomValues(32));
    return secretKey;
  }

  static Uint8List getRandomValues(int length) {
    Random random = Random();
    List<int> bytes = List<int>.generate(length, (_) => random.nextInt(128));
    return Uint8List.fromList(bytes);
  }

  static Future<String> secretKeyAsString(SecretKey secretKey) async {
    return utf8.decode(await secretKey.extractBytes());
  }

  static restoreSecretKeyFromString(String secretKeyStr){
    return SecretKey(utf8.encode(secretKeyStr));
  }

  static Future<String> encrypt(SecretKey secretKey, String plaintext) async {
    Uint8List plaintext0 = utf8.encode(plaintext);
    List<int> iv = AesGcm.with256bits().newNonce();
    SecretBox secretBox = await AesGcm.with256bits()
        .encrypt(plaintext0, nonce: iv, secretKey: secretKey);
    String encryptText = base64.encode(
        secretBox.concatenation()); // Base64 encoding of: IV | ciphertext | MAC
    return encryptText;
  }

  static Future<String> decrypt(SecretKey secretKey, String encryptText) async {
    Uint8List encryptText0 = base64.decode(encryptText);
    Uint8List iv = encryptText0.sublist(0, 12);
    Uint8List ciphertext = encryptText0.sublist(12, encryptText0.length - 16);
    Uint8List mac = encryptText0.sublist(encryptText0.length - 16);
    SecretBox secretBox = SecretBox(ciphertext, nonce: iv, mac: Mac(mac));
    List<int> decrypted =
        await AesGcm.with256bits().decrypt(secretBox, secretKey: secretKey);
    String plaintext = utf8.decode(decrypted);
    return plaintext;
  }
}
