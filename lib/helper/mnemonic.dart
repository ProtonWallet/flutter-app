import 'package:wallet/generated/bridge_definitions.dart' as bridge;
import 'package:wallet/helper/bdk_ffi.dart';
import 'package:wallet/helper/exceptions.dart';

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
      final res = await RustFFIProvider.bdkAPI
          .generateSeedFromWordCountStaticMethodApi(wordCount: wordCount);
      return Mnemonic._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Returns [Mnemonic] as string
  String asString() {
    return _mnemonic.toString();
  }

  // /// Create a new [Mnemonic] in the specified language from the given entropy.
  // /// Entropy must be a multiple of 32 bits (4 bytes) and 128-256 bits in length.
  // ///
  // /// [Mnemonic] constructor
  // static Future<Mnemonic> fromEntropy(typed_data.Uint8List entropy) async {
  //   try {
  //     final res =
  //         await bdkFfi.generateSeedFromEntropyStaticMethodApi(entropy: entropy);
  //     return Mnemonic._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // /// Parse a [Mnemonic] with given string
  // ///
  // /// [Mnemonic] constructor
  // static Future<Mnemonic> fromString(String mnemonic) async {
  //   try {
  //     final res = await bdkFfi.generateSeedFromStringStaticMethodApi(
  //         mnemonic: mnemonic);
  //     return Mnemonic._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // @override
  // String toString() {
  //   return asString();
  // }
}
