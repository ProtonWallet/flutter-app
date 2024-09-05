import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.mnemonic.g.dart';

@JsonSerializable()
class WalletMnemonic {
  final String walletID;
  final String mnemonic;

  WalletMnemonic({
    required this.walletID,
    required this.mnemonic,
  });

  /// Connect the generated [_$WalletMnemonicFromJson] function to the `fromJson`
  /// factory.
  factory WalletMnemonic.fromJson(Map<String, dynamic> json) =>
      _$WalletMnemonicFromJson(json);

  /// Connect the generated [_$WalletMnemonicToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$WalletMnemonicToJson(this);

  /// Handling a list of WalletPassphrase instances
  static List<WalletMnemonic> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => WalletMnemonic.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static String toJsonString(List<WalletMnemonic> items) {
    return json.encode(toJsonList(items));
  }

  static List<Map<String, dynamic>> toJsonList(List<WalletMnemonic> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static Future<List<WalletMnemonic>> loadJsonString(String jsonString) async {
    final decodedJsonList = json.decode(jsonString) as List<dynamic>;
    return fromJsonList(decodedJsonList);
  }
}
