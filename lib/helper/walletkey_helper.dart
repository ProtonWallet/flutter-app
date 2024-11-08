import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:wallet/rust/api/crypto/wallet_key.dart';
import 'package:wallet/rust/api/crypto/wallet_key_helper.dart';

class WalletKeyHelper {
  /// cryptographically secure pseudo-random number generation (CSPRNG)
  static Uint8List getSecureRandom(BigInt length) {
    return FrbWalletKeyHelper.getSecureRandom(length: length);
  }

  static Future<String> getHmacHashedString(
    FrbUnlockedWalletKey unlockedWalletKey,
    String message,
  ) async {
    final key = unlockedWalletKey.toEntropy();
    final bytes = utf8.encode(message);

    final hmacSha256 = crypto.Hmac(crypto.sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64Encode(digest.bytes);
  }
}
