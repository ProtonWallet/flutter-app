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

  WalletKey.fromApiWalletKey(ApiWalletKey item)
      : this(
          item.walletId,
          item.userKeyId,
          item.walletKey,
          item.walletKeySignature,
        );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is WalletKey &&
        walletId == other.walletId &&
        userKeyId == other.userKeyId &&
        walletKey == other.walletKey &&
        walletKeySignature == other.walletKeySignature;
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
    return jsonList
        .map((json) => WalletKey.fromJson(json as Map<String, dynamic>))
        .toList();
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

  static List<ApiWalletKey> toApiWalletKeys(List<WalletKey> items) {
    return items.map((item) => item.toApiWalletKey()).toList();
  }
}

extension WalletKeyExt on WalletKey {
  ApiWalletKey toApiWalletKey() {
    return ApiWalletKey(
      walletId: walletId,
      userKeyId: userKeyId,
      walletKey: walletKey,
      walletKeySignature: walletKeySignature,
    );
  }
}
