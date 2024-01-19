// import 'dart:typed_data';
// // import 'package:wallet/generated/bridge_definitions.dart' as bridge;
// import 'package:wallet/helper/bdk/exceptions.dart';
// import 'package:wallet/helper/rust.ffi.dart';
// import 'package:wallet/rust/error.dart';
// import 'package:wallet/rust/types.dart';

// ///A bitcoin transaction.
// class Transaction {
//   final String? _tx;
//   Transaction._(this._tx);

//   ///  [Transaction] constructor
//   static Future<Transaction> create({
//     required List<int> transactionBytes,
//   }) async {
//     try {
//       final tx = Uint8List.fromList(transactionBytes);
//       final res =
//           await RustFFIProvider.api.createTransactionStaticMethodApi(tx: tx);
//       return Transaction._(res);
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   ///Return the transaction bytes, bitcoin consensus encoded.
//   Future<List<int>> serialize() async {
//     try {
//       final res =
//           await RustFFIProvider.api.serializeTxStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<String> txid() async {
//     try {
//       final res = await RustFFIProvider.api.txTxidStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<int> weight() async {
//     try {
//       final res = await RustFFIProvider.api.weightStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<int> size() async {
//     try {
//       final res = await RustFFIProvider.api.sizeStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<int> vsize() async {
//     try {
//       final res = await RustFFIProvider.api.vsizeStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<bool> isCoinBase() async {
//     try {
//       final res = await RustFFIProvider.api.isCoinBaseStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<bool> isExplicitlyRbf() async {
//     try {
//       final res =
//           await RustFFIProvider.api.isExplicitlyRbfStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<bool> isLockTimeEnabled() async {
//     try {
//       final res =
//           await RustFFIProvider.api.isLockTimeEnabledStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<int> version() async {
//     try {
//       final res = await RustFFIProvider.api.versionStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<int> lockTime() async {
//     try {
//       final res = await RustFFIProvider.api.lockTimeStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<List<TxIn>> input() async {
//     try {
//       final res = await RustFFIProvider.api.inputStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<List<TxOut>> output() async {
//     try {
//       final res = await RustFFIProvider.api.outputStaticMethodApi(tx: _tx!);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   @override
//   String toString() {
//     return _tx!;
//   }
// }

// ///A Partially Signed Transaction
// class PartiallySignedTransaction {
//   final String psbtBase64;

//   PartiallySignedTransaction({required this.psbtBase64});

//   /// Combines this [PartiallySignedTransaction] with other PSBT as described by BIP 174.
//   ///
//   /// In accordance with BIP 174 this function is commutative i.e., `A.combine(B) == B.combine(A)`
//   Future<PartiallySignedTransaction> combine(
//       PartiallySignedTransaction other) async {
//     try {
//       final res = await RustFFIProvider.api.combinePsbtStaticMethodApi(
//           psbtStr: psbtBase64, other: other.psbtBase64);
//       return PartiallySignedTransaction(psbtBase64: res);
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   /// Return the transaction as bytes.
//   Future<Transaction> extractTx() async {
//     try {
//       final res = await RustFFIProvider.api
//           .extractTxStaticMethodApi(psbtStr: psbtBase64);
//       return Transaction._(res);
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   /// Return feeAmount
//   Future<int?> feeAmount() async {
//     try {
//       final res = await RustFFIProvider.api
//           .psbtFeeAmountStaticMethodApi(psbtStr: psbtBase64);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   // /// Return Fee Rate
//   // Future<FeeRate?> feeRate() async {
//   //   try {
//   //     final res = await RustFFIProvider.api
//   //         .psbtFeeRateStaticMethodApi(psbtStr: psbtBase64);
//   //     if (res == null) return null;
//   //     return FeeRate._(res);
//   //   } on Error catch (e) {
//   //     throw handleBdkException(e);
//   //   }
//   // }

//   /// Return txid as string
//   Future<String> serialize() async {
//     try {
//       final res = await RustFFIProvider.api
//           .serializePsbtStaticMethodApi(psbtStr: psbtBase64);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   Future<String> jsonSerialize() async {
//     try {
//       final res = await RustFFIProvider.api
//           .jsonSerializeStaticMethodApi(psbtStr: psbtBase64);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }

//   @override
//   String toString() {
//     return psbtBase64;
//   }

//   /// Returns the [PartiallySignedTransaction] transaction id
//   Future<String> txId() async {
//     try {
//       final res = await RustFFIProvider.api
//           .psbtTxidStaticMethodApi(psbtStr: psbtBase64);
//       return res;
//     } on Error catch (e) {
//       throw handleBdkException(e);
//     }
//   }
// }
