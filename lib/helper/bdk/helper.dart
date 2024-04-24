import 'dart:typed_data' as typed_data;

import 'package:flutter/foundation.dart';
import 'package:wallet/helper/bdk/exceptions.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/rust/bdk/blockchain.dart';
import 'package:wallet/rust/bdk/error.dart' as bridge;
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/rust/bdk/types.dart' as type;
import 'package:wallet/rust/bdk/wallet.dart';

// import 'utils/utils.dart';

// Future<void> setCurrentDirectory() async {
//   try {
//     await AppConfig.setBuildDirectory("${Directory.current.path}/build");
//   } catch (e) {
//     print(e.toString());
//   }
// }

///A Bitcoin address.
class Address {
  final String? _address;

  Address._(this._address);

  /// Creates an instance of [Address] from address given.
  ///
  /// Throws a [GenericException] if the address is not valid
  static Future<Address> create({required String address}) async {
    try {
      final res = await RustLib.instance.api.apiCreateAddress(address: address);
      return Address._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  // /// Creates an instance of [Address] from address given [Script].
  // ///
  // static Future<Address> fromScript(
  //     type.Script script, type.Network network) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .addressFromScriptStaticMethodApi(script: script, network: network);
  //     return Address._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // ///The type of the address.
  // ///
  // Future<type.Payload> payload() async {
  //   try {
  //     final res =
  //         await RustFFIProvider.api.payloadStaticMethodApi(address: _address!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<type.Network> network() async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .addressNetworkStaticMethodApi(address: _address!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// Returns the script pub key of the [Address] object
  Future<type.Script> scriptPubKey() async {
    try {
      final res = await RustLib.instance.api
          .apiAddressToScriptPubkey(address: _address.toString());
      return res;
    } on bridge.Error {
      rethrow;
    }
  }

  @override
  String toString() {
    return _address.toString();
  }
}

/// Blockchain backends  module provides the implementation of a few commonly-used backends like Electrum, and Esplora.
class Blockchain {
  // final BlockchainInstance? _blockchain;
  final String _blockchain;

  Blockchain._(this._blockchain);

  ///  [Blockchain] constructor
  static Future<Blockchain> create({required EsploraConfig config}) async {
    try {
      final res = await RustLib.instance.api
          .apiCreateEsploraBlockchainWithApi(config: config);
      return Blockchain._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// The function for getting block hash by block height
  Future<String> getBlockHash(int height) async {
    try {
      var res = await RustLib.instance.api.apiGetBlockchainHash(
          blockchainHeight: height, blockchainId: _blockchain);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// The function for getting the current height of the blockchain.
  Future<int> getHeight() async {
    try {
      var res =
          await RustLib.instance.api.apiGetHeight(blockchainId: _blockchain);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Estimate the fee rate required to confirm a transaction in a given target of blocks
  Future<FeeRate> estimateFee(int target) async {
    try {
      var res = await RustLib.instance.api
          .apiEstimateFee(blockchainId: _blockchain, target: target);
      return FeeRate._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// The function for broadcasting a transaction
  Future<void> broadcast(Transaction tx) async {
    try {
      final txid = await RustLib.instance.api
          .apiBroadcast(blockchainId: _blockchain, tx: tx._tx!);
      if (kDebugMode) {
        print(txid);
      }
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }
}

/// The BumpFeeTxBuilder is used to bump the fee on a transaction that has been broadcast and has its RBF flag set to true.
class BumpFeeTxBuilder {
  int? _nSequence;
  String? _allowShrinking;
  bool _enableRbf = false;
  final String txid;
  final double feeRate;

  BumpFeeTxBuilder({required this.txid, required this.feeRate});

  ///Explicitly tells the wallet that it is allowed to reduce the amount of the output matching this `address` in order to bump the transaction fee. Without specifying this the wallet will attempt to find a change output to shrink instead.
  ///
  /// Note that the output may shrink to below the dust limit and therefore be removed. If it is preserved then it is currently not guaranteed to be in the same position as it was originally.
  ///
  /// Throws and exception if address can’t be found among the recipients of the transaction we are bumping.
  BumpFeeTxBuilder allowShrinking(String address) {
    _allowShrinking = address;
    return this;
  }

  ///Enable signaling RBF
  ///
  /// This will use the default nSequence value of `0xFFFFFFFD`
  BumpFeeTxBuilder enableRbf() {
    _enableRbf = true;
    return this;
  }

  ///Enable signaling RBF with a specific nSequence value
  ///
  /// This can cause conflicts if the wallet’s descriptors contain an “older” (OP_CSV) operator and the given nsequence is lower than the CSV value.
  ///
  /// If the nsequence is higher than `0xFFFFFFFD` an error will be thrown, since it would not be a valid nSequence to signal RBF.

  BumpFeeTxBuilder enableRbfWithSequence(int nSequence) {
    _nSequence = nSequence;
    return this;
  }

  /// Finish building the transaction. Returns the  [TxBuilderResult].
  // Future<TxBuilderResult> finish(Wallet wallet) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .bumpFeeTxBuilderFinishStaticMethodApi(
  //             txid: txid.toString(),
  //             enableRbf: _enableRbf,
  //             feeRate: feeRate,
  //             walletId: wallet._wallet,
  //             nSequence: _nSequence,
  //             allowShrinking: _allowShrinking);
  //     return TxBuilderResult(
  //         psbt: PartiallySignedTransaction(psbtBase64: res.$1),
  //         txDetails: res.$2);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }
}

///A `BIP-32` derivation path
class DerivationPath {
  final String? _path;

  DerivationPath._(this._path);

  ///  [DerivationPath] constructor
  static Future<DerivationPath> create({required String path}) async {
    try {
      final res =
          await RustLib.instance.api.apiCreateDerivationPath(path: path);
      return DerivationPath._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  @override
  String toString() {
    return _path!;
  }
}

///Script descriptor
class Descriptor {
  final String _descriptorInstance;
  final type.Network _network;

  Descriptor._(this._descriptorInstance, this._network);

  ///  [Descriptor] constructor
  static Future<Descriptor> create(
      {required String descriptor, required type.Network network}) async {
    try {
      final res = await RustLib.instance.api
          .apiCreateDescriptor(descriptor: descriptor, network: network);
      return Descriptor._(res, network);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  Future<int> maxSatisfactionWeight() async {
    try {
      final res = await RustLib.instance.api.apiMaxSatisfactionWeight(
          descriptor: _descriptorInstance, network: _network);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  ///BIP44 template. Expands to pkh(key/44'/{0,1}'/0'/{0,1}/*)
  ///
  /// Since there are hardened derivation steps, this template requires a private derivable key (generally a xprv/tprv).
  static Future<Descriptor> newBip44(
      {required DescriptorSecretKey secretKey,
      required type.Network network,
      required type.KeychainKind keychain}) async {
    try {
      final res = await RustLib.instance.api.apiNewBip44Descriptor(
          secretKey: secretKey.asString(),
          network: network,
          keyChainKind: keychain);
      return Descriptor._(res, network);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  ///BIP44 public template. Expands to pkh(key/{0,1}/*)
  ///
  /// This assumes that the key used has already been derived with m/44'/0'/0' for Mainnet or m/44'/1'/0' for Testnet.
  ///
  /// This template requires the parent fingerprint to populate correctly the metadata of PSBTs.
  // static Future<Descriptor> newBip44Public(
  //     {required DescriptorPublicKey publicKey,
  //     required String fingerPrint,
  //     required type.Network network,
  //     required type.KeychainKind keychain}) async {
  //   try {
  //     final res = await RustFFIProvider.api.newBip44PublicStaticMethodApi(
  //         keyChainKind: keychain,
  //         publicKey: publicKey.asString(),
  //         network: network,
  //         fingerprint: fingerPrint);
  //     return Descriptor._(res, network);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///BIP49 template. Expands to sh(wpkh(key/49'/{0,1}'/0'/{0,1}/*))
  ///
  ///Since there are hardened derivation steps, this template requires a private derivable key (generally a xprv/tprv).
  // static Future<Descriptor> newBip49(
  //     {required DescriptorSecretKey secretKey,
  //     required type.Network network,
  //     required type.KeychainKind keychain}) async {
  //   try {
  //     final res = await RustFFIProvider.api.newBip49DescriptorStaticMethodApi(
  //         secretKey: secretKey.asString(),
  //         network: network,
  //         keyChainKind: keychain);
  //     return Descriptor._(res, network);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///BIP49 public template. Expands to sh(wpkh(key/{0,1}/*))
  ///
  /// This assumes that the key used has already been derived with m/49'/0'/0'.
  ///
  /// This template requires the parent fingerprint to populate correctly the metadata of PSBTs.
  // static Future<Descriptor> newBip49Public(
  //     {required DescriptorPublicKey publicKey,
  //     required String fingerPrint,
  //     required type.Network network,
  //     required type.KeychainKind keychain}) async {
  //   try {
  //     final res = await RustFFIProvider.api.newBip49PublicStaticMethodApi(
  //         keyChainKind: keychain,
  //         publicKey: publicKey.asString(),
  //         network: network,
  //         fingerprint: fingerPrint);
  //     return Descriptor._(res, network);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///BIP84 template. Expands to wpkh(key/84'/{0,1}'/0'/{0,1}/*)
  ///
  ///Since there are hardened derivation steps, this template requires a private derivable key (generally a xprv/tprv).
  static Future<Descriptor> newBip84(
      {required DescriptorSecretKey secretKey,
      required type.Network network,
      required type.KeychainKind keychain}) async {
    try {
      final res = await RustLib.instance.api.apiNewBip84Descriptor(
          secretKey: secretKey.asString(),
          network: network,
          keyChainKind: keychain);
      return Descriptor._(res, network);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  ///BIP84 public template. Expands to wpkh(key/{0,1}/*)
  ///
  /// This assumes that the key used has already been derived with m/84'/0'/0'.
  ///
  /// This template requires the parent fingerprint to populate correctly the metadata of PSBTs.
  // static Future<Descriptor> newBip84Public(
  //     {required DescriptorPublicKey publicKey,
  //     required String fingerPrint,
  //     required type.Network network,
  //     required type.KeychainKind keychain}) async {
  //   try {
  //     final res = await RustFFIProvider.api.newBip84PublicStaticMethodApi(
  //         keyChainKind: keychain,
  //         publicKey: publicKey.asString(),
  //         network: network,
  //         fingerprint: fingerPrint);
  //     return Descriptor._(res, network);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///Return the private version of the output descriptor if available, otherwise return the public version.
  // Future<String> asStringPrivate() async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .descriptorAsStringPrivateStaticMethodApi(
  //             descriptor: _descriptorInstance, network: _network);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///Return the public version of the output descriptor.
  // Future<String> asString() async {
  //   try {
  //     final res = await RustFFIProvider.api.descriptorAsStringStaticMethodApi(
  //         descriptor: _descriptorInstance, network: _network);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }
}

///An extended public key.
class DescriptorPublicKey {
  final String? _descriptorPublicKey;

  DescriptorPublicKey._(this._descriptorPublicKey);

  /// Get the public key as string.
  String asString() {
    return _descriptorPublicKey.toString();
  }

  ///Derive a public descriptor at a given path.
  // Future<DescriptorPublicKey> derive(DerivationPath derivationPath) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .createDescriptorPublicStaticMethodApi(
  //             xpub: _descriptorPublicKey,
  //             path: derivationPath._path.toString(),
  //             derive: true);
  //     return DescriptorPublicKey._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///Extend the public descriptor with a custom path.
  // Future<DescriptorPublicKey> extend(DerivationPath derivationPath) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .createDescriptorPublicStaticMethodApi(
  //             xpub: _descriptorPublicKey,
  //             path: derivationPath._path.toString(),
  //             derive: false);
  //     return DescriptorPublicKey._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// [DescriptorPublicKey] constructor
  // static Future<DescriptorPublicKey> fromString(String publicKey) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .descriptorPublicFromStringStaticMethodApi(publicKey: publicKey);
  //     return DescriptorPublicKey._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  @override
  String toString() {
    return asString();
  }
}

class DescriptorSecretKey {
  final String _descriptorSecretKey;

  DescriptorSecretKey._(this._descriptorSecretKey);

  ///Returns the public version of this key.
  ///
  /// If the key is an “XPrv”, the hardened derivation steps will be applied before converting it to a public key.
  // Future<DescriptorPublicKey> asPublic() async {
  //   try {
  //     final xpub = await RustFFIProvider.api
  //         .descriptorSecretAsPublicStaticMethodApi(
  //             secret: _descriptorSecretKey);
  //     return DescriptorPublicKey._(xpub);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// Get the private key as string.
  String asString() {
    return _descriptorSecretKey;
  }

  /// [DescriptorSecretKey] constructor
  static Future<DescriptorSecretKey> create(
      {required type.Network network,
      required Mnemonic mnemonic,
      String? password}) async {
    try {
      final res = await RustLib.instance.api.apiCreateDescriptorSecret(
          network: network, mnemonic: mnemonic.asString(), password: password);
      return DescriptorSecretKey._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Derived the `XPrv` using the derivation path
  Future<DescriptorSecretKey> derive(DerivationPath derivationPath) async {
    try {
      final res = await RustLib.instance.api.apiDeriveDescriptorSecret(
          secret: _descriptorSecretKey, path: derivationPath._path.toString());
      return DescriptorSecretKey._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Extends the “XPrv” using the derivation path
  // Future<DescriptorSecretKey> extend(DerivationPath derivationPath) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .extendDescriptorSecretStaticMethodApi(
  //             secret: _descriptorSecretKey,
  //             path: derivationPath._path.toString());
  //     return DescriptorSecretKey._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// [DescriptorSecretKey] constructor
  // static Future<DescriptorSecretKey> fromString(String secretKey) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .descriptorSecretFromStringStaticMethodApi(secret: secretKey);
  //     return DescriptorSecretKey._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// Get the private key as bytes.
  // Future<List<int>> secretBytes() async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .descriptorSecretAsSecretBytesStaticMethodApi(
  //             secret: _descriptorSecretKey);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  @override
  String toString() {
    return asString();
  }
}

class FeeRate {
  final double _feeRate;

  FeeRate._(this._feeRate);

  double asSatPerVb() {
    return _feeRate;
  }
}

/// A key-value map for an input of the corresponding index in the unsigned
/// transaction.
class Input {
  final String _input;

  Input._(this._input);

  @override
  String toString() {
    return _input.toString();
  }

  static Input create(String internal) {
    return Input._(internal);
  }
}

///A Partially Signed Transaction
class PartiallySignedTransaction {
  final String psbtBase64;

  PartiallySignedTransaction({required this.psbtBase64});

  /// Combines this [PartiallySignedTransaction] with other PSBT as described by BIP 174.
  ///
  /// In accordance with BIP 174 this function is commutative i.e., `A.combine(B) == B.combine(A)`
  // Future<PartiallySignedTransaction> combine(
  //     PartiallySignedTransaction other) async {
  //   try {
  //     final res = await RustFFIProvider.api.combinePsbtStaticMethodApi(
  //         psbtStr: psbtBase64, other: other.psbtBase64);
  //     return PartiallySignedTransaction(psbtBase64: res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// Return the transaction as bytes.
  Future<Transaction> extractTx() async {
    try {
      final res = await RustLib.instance.api.apiExtractTx(psbtStr: psbtBase64);
      return Transaction._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Return feeAmount
  // Future<int?> feeAmount() async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .psbtFeeAmountStaticMethodApi(psbtStr: psbtBase64);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// Return Fee Rate
  // Future<FeeRate?> feeRate() async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .psbtFeeRateStaticMethodApi(psbtStr: psbtBase64);
  //     if (res == null) return null;
  //     return FeeRate._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  /// Return txid as string
  // Future<String> serialize() async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .serializePsbtStaticMethodApi(psbtStr: psbtBase64);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  Future<String> jsonSerialize() async {
    try {
      final res =
          await RustLib.instance.api.apiJsonSerialize(psbtStr: psbtBase64);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  @override
  String toString() {
    return psbtBase64;
  }

  /// Returns the [PartiallySignedTransaction] transaction id
  // Future<String> txId() async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .psbtTxidStaticMethodApi(psbtStr: psbtBase64);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }
}

///Bitcoin script.
///
/// A list of instructions in a simple, Forth-like, stack-based programming language that Bitcoin uses.
///
/// See [Bitcoin Wiki: Script](https://en.bitcoin.it/wiki/Script) for more information.
class Script extends type.Script {
  Script._({required super.internal});

  /// [Script] constructor
  // static Future<type.Script> create(
  //     typed_data.Uint8List rawOutputScript) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .createScriptStaticMethodApi(rawOutputScript: rawOutputScript);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  typed_data.Uint8List toBytes() {
    return internal;
  }
}

///A bitcoin transaction.
class Transaction {
  final String? _tx;

  Transaction._(this._tx);

  ///  [Transaction] constructor
  // static Future<Transaction> create({
  //   required List<int> transactionBytes,
  // }) async {
  //   try {
  //     final tx = Uint8List.fromList(transactionBytes);
  //     final res =
  //         await RustFFIProvider.api.createTransactionStaticMethodApi(tx: tx);
  //     return Transaction._(res);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///Return the transaction bytes, bitcoin consensus encoded.
  // Future<List<int>> serialize() async {
  //   try {
  //     final res =
  //         await RustFFIProvider.api.serializeTxStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<String> txid() async {
  //   try {
  //     final res = await RustFFIProvider.api.txTxidStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<int> weight() async {
  //   try {
  //     final res = await RustFFIProvider.api.weightStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<int> size() async {
  //   try {
  //     final res = await RustFFIProvider.api.sizeStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<int> vsize() async {
  //   try {
  //     final res = await RustFFIProvider.api.vsizeStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<bool> isCoinBase() async {
  //   try {
  //     final res = await RustFFIProvider.api.isCoinBaseStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<bool> isExplicitlyRbf() async {
  //   try {
  //     final res =
  //         await RustFFIProvider.api.isExplicitlyRbfStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<bool> isLockTimeEnabled() async {
  //   try {
  //     final res =
  //         await RustFFIProvider.api.isLockTimeEnabledStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<int> version() async {
  //   try {
  //     final res = await RustFFIProvider.api.versionStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  // Future<int> lockTime() async {
  //   try {
  //     final res = await RustFFIProvider.api.lockTimeStaticMethodApi(tx: _tx!);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  Future<List<type.TxIn>> input() async {
    try {
      final res = await RustLib.instance.api.apiInput(tx: _tx!);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  Future<List<type.TxOut>> output() async {
    try {
      final res = await RustLib.instance.api.apiOutput(tx: _tx!);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  @override
  String toString() {
    return _tx!;
  }
}

///A transaction builder
///
/// A TxBuilder is created by calling TxBuilder or BumpFeeTxBuilder on a wallet.
/// After assigning it, you set options on it until finally calling finish to consume the builder and generate the transaction.
class TxBuilder {
  final List<type.ScriptAmount> _recipients = [];
  final List<type.OutPoint> _utxos = [];
  final List<type.OutPoint> _unSpendable = [];
  (type.OutPoint, String, int)? _foreignUtxo;
  bool _manuallySelectedOnly = false;
  double? _feeRate;
  type.ChangeSpendPolicy _changeSpendPolicy =
      type.ChangeSpendPolicy.changeAllowed;
  int? _feeAbsolute;
  bool _drainWallet = false;
  type.Script? _drainTo;
  type.RbfValue? _rbfValue;
  typed_data.Uint8List _data = typed_data.Uint8List.fromList([]);

  ///Add data as an output, using OP_RETURN
  TxBuilder addData({required List<int> data}) {
    if (data.isEmpty) {
      throw InvalidByteException(message: "List must not be empty");
    }
    _data = typed_data.Uint8List.fromList(data);
    return this;
  }

  ///Add a recipient to the internal list
  TxBuilder addRecipient(type.Script script, int amount) {
    _recipients.add(type.ScriptAmount(script: script, amount: amount));
    return this;
  }

  ///Add a utxo to the internal list of unspendable utxos
  ///
  /// It’s important to note that the “must-be-spent” utxos added with TxBuilder().addUtxo have priority over this.
  /// See the docs of the two linked methods for more details.
  TxBuilder unSpendable(List<type.OutPoint> outpoints) {
    for (var e in outpoints) {
      _unSpendable.add(e);
    }
    return this;
  }

  ///Add a utxo to the internal list of utxos that must be spent
  ///
  /// These have priority over the “unspendable” utxos, meaning that if a utxo is present both in the “utxos” and the “unspendable” list, it will be spent.
  TxBuilder addUtxo(type.OutPoint outpoint) {
    _utxos.add(outpoint);
    return this;
  }

  ///Add the list of outpoints to the internal list of UTXOs that must be spent.
  ///
  ///If an error occurs while adding any of the UTXOs then none of them are added and the error is returned.
  ///
  /// These have priority over the “unspendable” utxos, meaning that if a utxo is present both in the “utxos” and the “unspendable” list, it will be spent.
  TxBuilder addUtxos(List<type.OutPoint> outpoints) {
    for (var e in outpoints) {
      _utxos.add(e);
    }
    return this;
  }

  ///Add a foreign UTXO i.e. a UTXO not owned by this wallet.
  ///At a minimum to add a foreign UTXO we need:
  ///
  /// outpoint: To add it to the raw transaction.
  /// psbt_input: To know the value.
  /// satisfaction_weight: To know how much weight/vbytes the input will add to the transaction for fee calculation.
  /// There are several security concerns about adding foreign UTXOs that application developers should consider. First, how do you know the value of the input is correct? If a non_witness_utxo is provided in the psbt_input then this method implicitly verifies the value by checking it against the transaction. If only a witness_utxo is provided then this method doesn’t verify the value but just takes it as a given – it is up to you to check that whoever sent you the input_psbt was not lying!
  ///
  /// Secondly, you must somehow provide satisfaction_weight of the input. Depending on your application it may be important that this be known precisely.If not,
  /// a malicious counterparty may fool you into putting in a value that is too low, giving the transaction a lower than expected feerate. They could also fool
  /// you into putting a value that is too high causing you to pay a fee that is too high. The party who is broadcasting the transaction can of course check the
  /// real input weight matches the expected weight prior to broadcasting.
  TxBuilder addForeignUtxo(
      Input psbtInput, type.OutPoint outPoint, int satisfactionWeight) {
    _foreignUtxo = (outPoint, psbtInput._input, satisfactionWeight);
    return this;
  }

  ///Do not spend change outputs
  ///
  /// This effectively adds all the change outputs to the “unspendable” list. See TxBuilder().addUtxos
  TxBuilder doNotSpendChange() {
    _changeSpendPolicy = type.ChangeSpendPolicy.changeForbidden;
    return this;
  }

  ///Spend all the available inputs. This respects filters like TxBuilder().unSpendable and the change policy.
  TxBuilder drainWallet() {
    _drainWallet = true;
    return this;
  }

  ///Sets the address to drain excess coins to.
  ///
  /// Usually, when there are excess coins they are sent to a change address generated by the wallet.
  /// This option replaces the usual change address with an arbitrary scriptPubkey of your choosing.
  /// Just as with a change output, if the drain output is not needed (the excess coins are too small) it will not be included in the resulting transaction. T
  /// he only difference is that it is valid to use drainTo without setting any ordinary recipients with add_recipient (but it is perfectly fine to add recipients as well).
  ///
  /// If you choose not to set any recipients, you should either provide the utxos that the transaction should spend via add_utxos, or set drainWallet to spend all of them.
  ///
  /// When bumping the fees of a transaction made with this option, you probably want to use allowShrinking to allow this output to be reduced to pay for the extra fees.
  TxBuilder drainTo(type.Script script) {
    _drainTo = script;
    return this;
  }

  ///Enable signaling RBF with a specific nSequence value
  ///
  /// This can cause conflicts if the wallet’s descriptors contain an “older” (OP_CSV) operator and the given nsequence is lower than the CSV value.
  ///
  ///If the nsequence is higher than 0xFFFFFFFD an error will be thrown, since it would not be a valid nSequence to signal RBF.
  TxBuilder enableRbfWithSequence(int nSequence) {
    _rbfValue = type.RbfValue.value(nSequence);
    return this;
  }

  ///Enable signaling RBF
  ///
  /// This will use the default nSequence value of 0xFFFFFFFD.
  TxBuilder enableRbf() {
    _rbfValue = const type.RbfValue.rbfDefault();
    return this;
  }

  ///Set an absolute fee
  TxBuilder feeAbsolute(int feeAmount) {
    _feeAbsolute = feeAmount;
    return this;
  }

  ///Set a custom fee rate
  TxBuilder feeRate(double satPerVbyte) {
    _feeRate = satPerVbyte;
    return this;
  }

  ///Replace the recipients already added with a new list
  TxBuilder setRecipients(List<type.ScriptAmount> recipients) {
    for (var e in _recipients) {
      _recipients.add(e);
    }
    return this;
  }

  ///Only spend utxos added by add_utxo.
  ///
  /// The wallet will not add additional utxos to the transaction even if they are needed to make the transaction valid.
  TxBuilder manuallySelectedOnly() {
    _manuallySelectedOnly = true;
    return this;
  }

  ///Add a utxo to the internal list of unspendable utxos
  ///
  /// It’s important to note that the “must-be-spent” utxos added with TxBuilder().addUtxo
  /// have priority over this. See the docs of the two linked methods for more details.
  TxBuilder addUnSpendable(type.OutPoint unSpendable) {
    _unSpendable.add(unSpendable);
    return this;
  }

  ///Only spend change outputs
  ///
  /// This effectively adds all the non-change outputs to the “unspendable” list.
  TxBuilder onlySpendChange() {
    _changeSpendPolicy = type.ChangeSpendPolicy.onlyChange;
    return this;
  }

  ///Finish building the transaction.
  ///
  /// Returns a [TxBuilderResult].

  Future<TxBuilderResult> finish(Wallet wallet) async {
    if (_recipients.isEmpty && _drainTo == null) {
      throw NoRecipientsException();
    }
    try {
      final res = await RustLib.instance.api.apiTxBuilderFinish(
          walletId: wallet._wallet,
          recipients: _recipients,
          utxos: _utxos,
          foreignUtxo: _foreignUtxo,
          unspendable: _unSpendable,
          manuallySelectedOnly: _manuallySelectedOnly,
          drainWallet: _drainWallet,
          rbf: _rbfValue,
          drainTo: _drainTo,
          feeAbsolute: _feeAbsolute,
          feeRate: _feeRate,
          data: _data,
          changePolicy: _changeSpendPolicy);

      return TxBuilderResult(
          psbt: PartiallySignedTransaction(psbtBase64: res.$1),
          txDetails: res.$2);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }
}

///The value returned from calling the .finish() method on the [TxBuilder] or [BumpFeeTxBuilder].
class TxBuilderResult {
  final PartiallySignedTransaction psbt;

  ///The transaction details.
  ///
  final type.TransactionDetails txDetails;

  TxBuilderResult({required this.psbt, required this.txDetails});
}

/// A Bitcoin wallet.
///
/// The Wallet acts as a way of coherently interfacing with output descriptors and related transactions. Its main components are:
///
///     1. Output descriptors from which it can derive addresses.
///
///     2. A Database where it tracks transactions and utxos related to the descriptors.
///
///     3. Signers that can contribute signatures to addresses instantiated from the descriptors.
///
class Wallet {
  final String _wallet;

  Wallet._(this._wallet);

  ///  [Wallet] constructor
  static Future<Wallet> create({
    required Descriptor descriptor,
    Descriptor? changeDescriptor,
    required type.Network network,
    required DatabaseConfig databaseConfig,
  }) async {
    try {
      final res = await RustLib.instance.api.apiCreateWallet(
        descriptor: descriptor._descriptorInstance,
        changeDescriptor: changeDescriptor?._descriptorInstance,
        network: network,
        databaseConfig: databaseConfig,
      );
      return Wallet._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  ///Return a derived address using the external descriptor, see [AddressIndex] for available address index selection strategies.
  /// If none of the keys in the descriptor are derivable (i.e. does not end with /*) then the same address will always be returned for any AddressIndex.
  Future<type.AddressInfo> getAddress(
      {required type.AddressIndex addressIndex}) async {
    try {
      var res = await RustLib.instance.api
          .apiGetAddress(walletId: _wallet, addressIndex: addressIndex);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Return a derived address using the internal (change) descriptor.
  ///
  /// If the wallet doesn't have an internal descriptor it will use the external descriptor.
  ///
  /// see [AddressIndex] for available address index selection strategies. If none of the keys
  /// in the descriptor are derivable (i.e. does not end with /*) then the same address will always
  /// be returned for any [AddressIndex].
  // Future<type.AddressInfo> getInternalAddress(
  //     {required type.AddressIndex addressIndex}) async {
  //   try {
  //     var res = await RustFFIProvider.api.getInternalAddressStaticMethodApi(
  //         walletId: _wallet, addressIndex: addressIndex);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///Return the [Balance], separated into available, trusted-pending, untrusted-pending and immature values.
  ///
  ///Note that this method only operates on the internal database, which first needs to be Wallet().sync manually.
  Future<type.Balance> getBalance() async {
    try {
      var res = await RustLib.instance.api.apiGetBalance(walletId: _wallet);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Return whether or not a script is part of this wallet (either internal or external).
  // Future<bool> isMine(type.Script script) async {
  //   try {
  //     var res = await RustFFIProvider.api
  //         .isMineStaticMethodApi(script: script, walletId: _wallet);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///Get the Bitcoin network the wallet is using.
  // Future<type.Network> network() async {
  //   try {
  //     var res = await RustFFIProvider.api
  //         .walletNetworkStaticMethodApi(walletId: _wallet);
  //     return res;
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }

  ///Return the list of unspent outputs of this wallet
  ///
  /// Note that this method only operates on the internal database, which first needs to be Wallet().sync manually.
  Future<List<LocalUtxo>> listUnspent() async {
    try {
      var res =
          await RustLib.instance.api.apiListUnspentOutputs(walletId: _wallet);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  ///Sync the internal database with the [Blockchain]
  Future syncWallet(Blockchain blockchain) async {
    try {
      RustLib.instance.api.apiSyncWallet(
          walletId: _wallet, blockchainId: blockchain._blockchain);
      debugPrint('sync complete');
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  ///Return an unsorted list of transactions made and received by the wallet
  Future<List<type.TransactionDetails>> listTransactions(
      bool includeRaw) async {
    try {
      final res = await RustLib.instance.api
          .apiGetTransactions(walletId: _wallet, includeRaw: includeRaw);
      return res;
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  ///Sign a transaction with all the wallet’s signers, in the order specified by every signer’s SignerOrdering
  ///
  /// Note that it can’t be guaranteed that every signers will follow the options, but the “software signers” (WIF keys and xprv) defined in this library will.
  Future<PartiallySignedTransaction> sign(
      {required PartiallySignedTransaction psbt,
      SignOptions? signOptions}) async {
    try {
      final sbt = await RustLib.instance.api.apiSign(
          signOptions: signOptions,
          psbtStr: psbt.psbtBase64,
          walletId: _wallet);
      if (sbt == null) {
        throw SignerException(message: "Unable to sign transaction");
      }
      return PartiallySignedTransaction(psbtBase64: sbt);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  Future<Input> getPsbtInput({
    required LocalUtxo utxo,
    required bool onlyWitnessUtxo,
    type.PsbtSigHashType? psbtSighashType,
  }) async {
    try {
      final res = await RustLib.instance.api.apiGetPsbtInput(
          walletId: _wallet,
          utxo: utxo,
          onlyWitnessUtxo: onlyWitnessUtxo,
          psbtSighashType: psbtSighashType);
      return Input._(res);
    } on bridge.Error catch (e) {
      throw handleBdkException(e);
    }
  }

  /// Returns the descriptor used to create addresses for a particular `keychain`.
  // Future<Descriptor> getDescriptorForKeyChain(
  //     type.KeychainKind keychainKind) async {
  //   try {
  //     final res = await RustFFIProvider.api
  //         .getDescriptorForKeychainStaticMethodApi(
  //             walletId: _wallet, keychain: keychainKind);
  //     return Descriptor._(res.$1, res.$2);
  //   } on bridge.Error catch (e) {
  //     throw handleBdkException(e);
  //   }
  // }
}

extension Tx on type.TransactionDetails {
  Transaction? get transaction =>
      serializedTx == null ? null : Transaction._(serializedTx);
}
