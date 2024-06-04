import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.passphrase.g.dart';

@JsonSerializable()
class WalletPassphrase {
  final String walletID;
  final String passphrase;

  WalletPassphrase({
    required this.walletID,
    required this.passphrase,
  });

  /// Connect the generated [_$WalletPassphraseFromJson] function to the `fromJson`
  /// factory.
  factory WalletPassphrase.fromJson(Map<String, dynamic> json) =>
      _$WalletPassphraseFromJson(json);

  /// Connect the generated [_$RWalletPassphraseToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$WalletPassphraseToJson(this);

  /// Handling a list of WalletPassphrase instances
  static List<WalletPassphrase> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WalletPassphrase.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<WalletPassphrase> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static Future<List<WalletPassphrase>> loadJsonString(
      String jsonString) async {
    final decodedJsonList = json.decode(jsonString) as List<dynamic>;
    return fromJsonList(decodedJsonList);
  }
}
