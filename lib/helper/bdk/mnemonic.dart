import 'dart:typed_data' as typed_data;
// import 'package:wallet/generated/bridge_definitions.dart' as bridge;
import 'package:wallet/helper/bdk/exceptions.dart';
import 'package:wallet/rust/error.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/rust/types.dart';

/// Mnemonic phrases are a human-readable version of the private keys.
/// Supported number of words are 12, 18, and 24.
class Mnemonic {
  final String? _mnemonic;
  Mnemonic._(this._mnemonic);

  /// Generates [Mnemonic] with given [WordCount]
  ///
  /// [Mnemonic] constructor
  static Future<Mnemonic> create(WordCount wordCount) async {
    try {
      final res = await RustLib.instance.api
          .apiGenerateSeedFromWordCount(wordCount: wordCount);
      return Mnemonic._(res);
    } on Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Create a new [Mnemonic] in the specified language from the given entropy.
  /// Entropy must be a multiple of 32 bits (4 bytes) and 128-256 bits in length.
  ///
  /// [Mnemonic] constructor
  static Future<Mnemonic> fromEntropy(typed_data.Uint8List entropy) async {
    try {
      final res = await RustLib.instance.api
          .apiGenerateSeedFromEntropy(entropy: entropy);
      return Mnemonic._(res);
    } on Error catch (e) {
      throw handleBdkException(e);
    }
  }

  static Future<Mnemonic> fromString(String mnemonic) async {
    try {
      final res = await RustLib.instance.api
          .apiGenerateSeedFromString(mnemonic: mnemonic);
      return Mnemonic._(res);
    } on Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Returns [Mnemonic] as string
  String asString() {
    return _mnemonic.toString();
  }
}
