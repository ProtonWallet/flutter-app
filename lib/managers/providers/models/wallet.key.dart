import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

part 'wallet.key.g.dart';

@JsonSerializable()
class WalletKey {
  final String walletId;
  final String userKeyId;
  final String walletKey;
  final String walletKeySignature;

  WalletKey(
      this.walletId, this.userKeyId, this.walletKey, this.walletKeySignature);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final WalletKey otherKey = other as WalletKey;
    return walletId == otherKey.walletId;
  }

  @override
  int get hashCode => walletId.hashCode;

  /// Connect the generated [_$WalletKeyFromJson] function to the `fromJson`
  /// factory.
  factory WalletKey.fromJson(Map<String, dynamic> json) =>
      _$WalletKeyFromJson(json);

  /// Connect the generated [_$WalletKeyToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$WalletKeyToJson(this);

  /// Handling a list of WalletPassphrase instances
  static List<WalletKey> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WalletKey.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<WalletKey> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static String toJsonString(List<WalletKey> items) {
    return json.encode(toJsonList(items));
  }

  static Future<List<WalletKey>> loadJsonString(String jsonString) async {
    if (jsonString.isEmpty) {
      return [];
    }
    final decodedJsonList = json.decode(jsonString) as List<dynamic>;
    return fromJsonList(decodedJsonList);
  }

  static List<WalletKey> fromApiWalletKeys(List<ApiWalletKey> items) {
    return items
        .map((item) => WalletKey(
              item.walletId,
              item.userKeyId,
              item.walletKey,
              item.walletKeySignature,
            ))
        .toList();
  }

  static WalletKey fromApiWalletKey(ApiWalletKey item) {
    return WalletKey(
      item.walletId,
      item.userKeyId,
      item.walletKey,
      item.walletKeySignature,
    );
  }
}
