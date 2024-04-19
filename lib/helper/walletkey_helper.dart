import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';

class WalletKeyHelper {
  static SecretKey generateSecretKey() {
    SecretKey secretKey = SecretKey(getRandomValues(32));
    return secretKey;
  }

  static Uint8List getRandomValues(int length) {
    Random random = Random();
    List<int> bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return Uint8List.fromList(bytes);
  }

  static Future<String> getEncodedEntropy(SecretKey secretKey) async {
    return base64Encode(await secretKey.extractBytes());
  }

  static restoreSecretKeyFromEncodedEntropy(String encodedEntropy) {
    return SecretKey(base64Decode(encodedEntropy));
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

  static Future<String> getHmacHashedString(SecretKey secretKey, String message) async{
    var key = await secretKey.extractBytes();
    var bytes = utf8.encode(message);

    var hmacSha256 = crypto.Hmac(crypto.sha256, key);
    var digest = hmacSha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  static Future<String> decrypt(SecretKey secretKey, String encryptText) async {
    if (encryptText.isEmpty){
      return "";
    }
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
