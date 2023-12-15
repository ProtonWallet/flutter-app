import 'package:wallet/generated/bridge_definitions.dart' as bridge;
import 'package:wallet/helper/bdk/exceptions.dart';
import 'package:wallet/helper/rust.ffi.dart';

/// Blockchain backends  module provides the implementation of a few commonly-used backends like Electrum, and Esplora.
class Blockchain {
  // final BlockchainInstance? _blockchain;
  final String _blockchain;
  Blockchain._(this._blockchain);

  ///  [Blockchain] constructor
  static Future<Blockchain> create(
      {required bridge.EsploraConfig config}) async {
    try {
      final res = await RustFFIProvider.api
          .createEsploraBlockchainStaticMethodApi(config: config);
      return Blockchain._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// The function for getting block hash by block height
  Future<String> getBlockHash(int height) async {
    try {
      var res = await RustFFIProvider.api.getBlockchainHashStaticMethodApi(
          blockchainHeight: height, blockchainId: _blockchain);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// The function for getting the current height of the blockchain.
  Future<int> getHeight() async {
    try {
      var res = await RustFFIProvider.api
          .getHeightStaticMethodApi(blockchainId: _blockchain);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Estimate the fee rate required to confirm a transaction in a given target of blocks
  // Future<FeeRate> estimateFee(int target) async {
  //   try {
  //     var res = await RustFFIProvider.api.estimateFeeStaticMethodApi(
  //         blockchainId: _blockchain, target: target);
  //     return FeeRate._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// The function for broadcasting a transaction
  // Future<void> broadcast(Transaction tx) async {
  //   try {
  //     final txid = await RustFFIProvider.api
  //         .broadcastStaticMethodApi(blockchainId: _blockchain, tx: tx._tx!);
  //     if (kDebugMode) {
  //       print(txid);
  //     }
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }
}
