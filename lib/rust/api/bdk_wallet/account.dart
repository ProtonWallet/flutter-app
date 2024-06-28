// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.33.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../common/address_info.dart';
import '../../common/errors.dart';
import '../../common/keychain_kind.dart';
import '../../common/network.dart';
import '../../common/pagination.dart';
import '../../common/script_type.dart';
import '../../frb_generated.dart';
import 'address.dart';
import 'balance.dart';
import 'derivation_path.dart';
import 'local_output.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'payment_link.dart';
import 'psbt.dart';
import 'storage.dart';
import 'transaction_builder.dart';
import 'transaction_details.dart';
import 'wallet.dart';

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<FrbAccount>>
@sealed
class FrbAccount extends RustOpaque {
  FrbAccount.dcoDecode(List<dynamic> wire)
      : super.dcoDecode(wire, _kStaticData);

  FrbAccount.sseDecode(int ptr, int externalSizeOnNative)
      : super.sseDecode(ptr, externalSizeOnNative, _kStaticData);

  static final _kStaticData = RustArcStaticData(
    rustArcIncrementStrongCount:
        RustLib.instance.api.rust_arc_increment_strong_count_FrbAccount,
    rustArcDecrementStrongCount:
        RustLib.instance.api.rust_arc_decrement_strong_count_FrbAccount,
    rustArcDecrementStrongCountPtr:
        RustLib.instance.api.rust_arc_decrement_strong_count_FrbAccountPtr,
  );

  Future<FrbTxBuilder> buildTx({dynamic hint}) =>
      RustLib.instance.api.frbAccountBuildTx(that: this, hint: hint);

  Future<FrbAddressInfo> getAddress({int? index, dynamic hint}) =>
      RustLib.instance.api
          .frbAccountGetAddress(that: this, index: index, hint: hint);

  Future<FrbBalance> getBalance({dynamic hint}) =>
      RustLib.instance.api.frbAccountGetBalance(that: this, hint: hint);

  Future<FrbPaymentLink> getBitcoinUri(
          {int? index,
          int? amount,
          String? label,
          String? message,
          dynamic hint}) =>
      RustLib.instance.api.frbAccountGetBitcoinUri(
          that: this,
          index: index,
          amount: amount,
          label: label,
          message: message,
          hint: hint);

  Future<String> getDerivationPath({dynamic hint}) =>
      RustLib.instance.api.frbAccountGetDerivationPath(that: this, hint: hint);

  Future<int?> getLastUnusedAddressIndex({dynamic hint}) => RustLib.instance.api
      .frbAccountGetLastUnusedAddressIndex(that: this, hint: hint);

  Future<FrbTransactionDetails> getTransaction(
          {required String txid, dynamic hint}) =>
      RustLib.instance.api
          .frbAccountGetTransaction(that: this, txid: txid, hint: hint);

  Future<List<FrbTransactionDetails>> getTransactions(
          {Pagination? pagination, SortOrder? sort, dynamic hint}) =>
      RustLib.instance.api.frbAccountGetTransactions(
          that: this, pagination: pagination, sort: sort, hint: hint);

  Future<List<FrbLocalOutput>> getUtxos({dynamic hint}) =>
      RustLib.instance.api.frbAccountGetUtxos(that: this, hint: hint);

  Future<bool> hasSyncData({dynamic hint}) =>
      RustLib.instance.api.frbAccountHasSyncData(that: this, hint: hint);

  Future<void> insertUnconfirmedTx({required FrbPsbt psbt, dynamic hint}) =>
      RustLib.instance.api
          .frbAccountInsertUnconfirmedTx(that: this, psbt: psbt, hint: hint);

  Future<bool> isMine({required FrbAddress address, dynamic hint}) =>
      RustLib.instance.api
          .frbAccountIsMine(that: this, address: address, hint: hint);

  /// Usually creating account need to through wallet.
  ///  this shouldn't be used. just for sometimes we need it without wallet.
  factory FrbAccount(
          {required FrbWallet wallet,
          required ScriptType scriptType,
          required FrbDerivationPath derivationPath,
          required OnchainStoreFactory storageFactory,
          dynamic hint}) =>
      RustLib.instance.api.frbAccountNew(
          wallet: wallet,
          scriptType: scriptType,
          derivationPath: derivationPath,
          storageFactory: storageFactory,
          hint: hint);

  Future<FrbPsbt> sign(
          {required FrbPsbt psbt, required Network network, dynamic hint}) =>
      RustLib.instance.api
          .frbAccountSign(that: this, psbt: psbt, network: network, hint: hint);
}