// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../../frb_generated.dart';
import '../../errors.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'wallet_key.dart';

class FrbWalletKeyHelper {
  const FrbWalletKeyHelper();

  /// Decrypts the encrypted text using AES-GCM with 256-bit key.
  static String decrypt(
          {required String base64SecureKey, required String encryptText}) =>
      RustLib.instance.api
          .crateApiProtonWalletCryptoWalletKeyHelperFrbWalletKeyHelperDecrypt(
              base64SecureKey: base64SecureKey, encryptText: encryptText);

  /// Encrypts the plaintext using AES-GCM with 256-bit key.
  static String encrypt(
          {required String base64SecureKey, required String plaintext}) =>
      RustLib.instance.api
          .crateApiProtonWalletCryptoWalletKeyHelperFrbWalletKeyHelperEncrypt(
              base64SecureKey: base64SecureKey, plaintext: plaintext);

  static FrbUnlockedWalletKey generateSecretKey() => RustLib.instance.api
      .crateApiProtonWalletCryptoWalletKeyHelperFrbWalletKeyHelperGenerateSecretKey();

  static String generateSecretKeyAsBase64() => RustLib.instance.api
      .crateApiProtonWalletCryptoWalletKeyHelperFrbWalletKeyHelperGenerateSecretKeyAsBase64();

  /// Cryptographically secure pseudo-random number generation (CSPRNG).
  static Uint8List getSecureRandom({required BigInt length}) => RustLib
      .instance.api
      .crateApiProtonWalletCryptoWalletKeyHelperFrbWalletKeyHelperGetSecureRandom(
          length: length);

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrbWalletKeyHelper && runtimeType == other.runtimeType;
}