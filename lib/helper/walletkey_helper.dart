import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/constants.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/users/user.key.dart';
import 'package:wallet/rust/api/crypto/wallet_key_helper.dart';

class WalletKeyHelper {
  static SecretKey generateSecretKey() {
    final frbSecretKey = FrbWalletKeyHelper.generateSecretKey();
    return SecretKey(frbSecretKey.toEntropy());
  }

  /// generate random values
  static Uint8List getRandomValues(int length) {
    final Random random = Random();
    final List<int> bytes =
        List<int>.generate(length, (_) => random.nextInt(256));
    return Uint8List.fromList(bytes);
  }

  /// cryptographically secure pseudo-random number generation (CSPRNG)
  static Uint8List getSecureRandom(BigInt length) {
    return FrbWalletKeyHelper.getSecureRandom(length: length);
  }

  static Future<String> getEncodedEntropy(SecretKey secretKey) async {
    return base64Encode(await secretKey.extractBytes());
  }

  static SecretKey restoreSecretKeyFromEncodedEntropy(String encodedEntropy) {
    return SecretKey(base64Decode(encodedEntropy));
  }

  static SecretKey restoreSecretKeyFromEntropy(Uint8List entropy) {
    return SecretKey(entropy);
  }

  static Future<String> encrypt(
    SecretKey secretKey,
    String plaintext, {
    List<int>? initIV,
  }) async {
    final Uint8List bytes = utf8.encode(plaintext);
    List<int> iv = AesGcm.with256bits().newNonce();
    if (initIV != null) {
      iv = initIV;
    }
    final SecretBox secretBox = await AesGcm.with256bits()
        .encrypt(bytes, nonce: iv, secretKey: secretKey);
    final String encryptText = base64Encode(
        secretBox.concatenation()); // Base64 encoding of: IV | ciphertext | MAC
    return encryptText;
  }

  static Future<String> getHmacHashedString(
    SecretKey secretKey,
    String message,
  ) async {
    final key = await secretKey.extractBytes();
    final bytes = utf8.encode(message);

    final hmacSha256 = crypto.Hmac(crypto.sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  static Future<String> decrypt(SecretKey secretKey, String encryptText) async {
    if (encryptText.isEmpty) {
      return "";
    }
    final Uint8List bytes = base64Decode(encryptText);
    final Uint8List iv = bytes.sublist(0, 12);
    final Uint8List ciphertext = bytes.sublist(12, bytes.length - 16);
    final Uint8List mac = bytes.sublist(bytes.length - 16);
    final SecretBox secretBox = SecretBox(ciphertext, nonce: iv, mac: Mac(mac));
    final List<int> decrypted =
        await AesGcm.with256bits().decrypt(secretBox, secretKey: secretKey);
    final String plaintext = utf8.decode(decrypted);
    return plaintext;
  }

  /// decrypt wallet key by user key
  static SecretKey decryptWalletKey(
    UserKey userKey,
    WalletKey walletKey,
  ) {
    final pgpBinaryMessage = walletKey.walletKey;
    final entropy = proton_crypto.decryptBinaryPGP(
      userKey.privateKey,
      userKey.passphrase,
      pgpBinaryMessage,
    );
    final secretKey = restoreSecretKeyFromEntropy(entropy);
    return secretKey;
  }

  /// verify wallet key signature by user key
  static Future<bool> verifySecretKeySignature(
    UserKey userKey,
    WalletKey walletKey,
    SecretKey secretKey,
  ) async {
    final userPublicKey = proton_crypto.getArmoredPublicKey(userKey.privateKey);
    final signature = walletKey.walletKeySignature;
    final Uint8List entropy =
        Uint8List.fromList(await secretKey.extractBytes());
    // check signature
    final isValidWalletKeySignature =
        proton_crypto.verifyBinarySignatureWithContext(
      userPublicKey,
      entropy,
      signature,
      gpgContextWalletKey,
    );
    return isValidWalletKeySignature;
  }
}
