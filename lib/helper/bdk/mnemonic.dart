import 'dart:typed_data' as typed_data;
import 'package:wallet/generated/bridge_definitions.dart' as bridge;
import 'package:wallet/helper/bdk/exceptions.dart';
import 'package:wallet/helper/rust.ffi.dart';

/// Mnemonic phrases are a human-readable version of the private keys.
/// Supported number of words are 12, 18, and 24.
class Mnemonic {
  final String? _mnemonic;
  Mnemonic._(this._mnemonic);

  /// Generates [Mnemonic] with given [WordCount]
  ///
  /// [Mnemonic] constructor
  static Future<Mnemonic> create(bridge.WordCount wordCount) async {
    try {
      final res = await RustFFIProvider.api
          .generateSeedFromWordCountStaticMethodApi(wordCount: wordCount);
      return Mnemonic._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Create a new [Mnemonic] in the specified language from the given entropy.
  /// Entropy must be a multiple of 32 bits (4 bytes) and 128-256 bits in length.
  ///
  /// [Mnemonic] constructor
  static Future<Mnemonic> fromEntropy(typed_data.Uint8List entropy) async {
    try {
      final res = await RustFFIProvider.api
          .generateSeedFromEntropyStaticMethodApi(entropy: entropy);
      return Mnemonic._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Returns [Mnemonic] as string
  String asString() {
    return _mnemonic.toString();
  }
}
