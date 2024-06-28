import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/rust_api.dart';
import 'package:wallet/rust/frb_generated.dart';

class BdkLibrary {
  Future<void> clearLocalCache() async {
    String? path;
    if (Platform.isWindows || Platform.isLinux) {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      path = join(appDocumentsDir.path, "databases");
    } else {
      path = await getDatabasesPath();
      if (!path.contains("databases")) {
        path = join(path, "databases");
      }
    }

    final dir = Directory(path);
    if (await dir.exists()) {
      List<FileSystemEntity> entities = dir.listSync();
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          String fileName = basename(entity.path);
          bool delete = false;
          if (!delete && fileName.endsWith(".sqlite")) {
            delete = true;
          }
          if (!delete && fileName.endsWith("true.db")) {
            delete = true;
          }
          if (!delete && fileName.endsWith("false.db")) {
            delete = true;
          }
          if (!delete && fileName.contains("_m_")) {
            delete = true;
          }
          if (delete) {
            logger.i("removing bdk db: ${entity.path}");
            entity.deleteSync();
          }
        }
      }
    }
  }

  Future<bool> fullSyncWalletWithWallet(
    int walletID,
    int accountID,
  ) async {
    try {
      // Define the function to be run in the isolate
      Future<void> isolateTask(int walletID, int accountID) async {
        await RustLib.init();
        var account = await WalletManager.loadWalletWithID(walletID, accountID);
        var blockClient = await Api.createEsploraBlockchainWithApi();
        await blockClient.fullSync(
          account: account!,
          stopGap: appConfig.stopGap,
        );
        RustLib.dispose();
      }

      await Isolate.run(() => isolateTask(walletID, accountID));
      return true;
    } on FormatException catch (e, stacktrace) {
      logger.e(
        "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}",
      );
    } catch (e, stacktrace) {
      logger.e(
        "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}",
      );
    }
    return false;
  }

  Future<void> partialSyncWalletWithID(
    FrbBlockchainClient blockchain,
    FrbAccount account,
  ) async {
    try {
      await Isolate.run(() async => {
            await RustLib.init(),
            if (await blockchain.shouldSync(account: account))
              {
                await blockchain.partialSync(account: account),
              },
            RustLib.dispose()
          });
    } on FormatException catch (e, stacktrace) {
      logger.e(
        "Bdk wallet partial sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}",
      );
    }
  }

  Future<bool> fullSyncWallet(
    FrbBlockchainClient blockchain,
    FrbAccount account,
  ) async {
    try {
      await blockchain.fullSync(
        account: account,
        stopGap: appConfig.stopGap,
      );
      return true;
    } on FormatException catch (e, stacktrace) {
      logger.e(
          "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}");
    } catch (e, stacktrace) {
      logger.e(
          "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}");
    }
    return false;
  }

  Future<void> partialSyncWallet(
      FrbBlockchainClient blockchain, FrbAccount account) async {
    try {
      await Isolate.run(() async => {
            await RustLib.init(),
            if (await blockchain.shouldSync(account: account))
              {
                await blockchain.partialSync(account: account),
              },
            RustLib.dispose()
          });
    } on FormatException catch (e, stacktrace) {
      logger.e(
          "Bdk wallet partial sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}");
    }
  }

//   Future<AddressInfo> getAddress(Wallet aliceWallet,
//       {int? addressIndex}) async {
//     AddressInfo addressInfo;
//     if (addressIndex != null) {
//       addressInfo = await aliceWallet.getAddress(
//           addressIndex: AddressIndex.peek(index: addressIndex));
//     } else {
//       addressInfo =
//           await aliceWallet.getAddress(addressIndex: const AddressIndex());
//     }
//     return addressInfo;
//   }

//   Future<Input> getPsbtInput(
//       Wallet aliceWallet, LocalUtxo utxo, bool onlyWitnessUtxo) async {
//     final input = await aliceWallet.getPsbtInput(
//         utxo: utxo, onlyWitnessUtxo: onlyWitnessUtxo);
//     return input;
//   }

//   Future<List<TransactionDetails>> getUnConfirmedTransactions(
//       Wallet aliceWallet) async {
//     List<TransactionDetails> unConfirmed = [];
//     final res = await aliceWallet.listTransactions(true);
//     for (var e in res) {
//       if (e.confirmationTime == null) unConfirmed.add(e);
//     }
//     return unConfirmed;
//   }

//   Future<List<TransactionDetails>> getConfirmedTransactions(
//       Wallet aliceWallet) async {
//     List<TransactionDetails> confirmed = [];
//     final res = await aliceWallet.listTransactions(true);

//     for (var e in res) {
//       if (e.confirmationTime != null) confirmed.add(e);
//     }
//     return confirmed;
//   }

//   Future<List<TransactionDetails>> getAllTransactions(
//       Wallet aliceWallet) async {
//     return await aliceWallet.listTransactions(true);
//   }

//   Future<Balance> getBalance(Wallet aliceWallet) async {
//     final res = await aliceWallet.getBalance();
//     return res;
//   }

//   Future<List<LocalUtxo>> listUnspend(Wallet aliceWallet) async {
//     final res = await aliceWallet.listUnspent();
//     return res;
//   }

//   Future<FeeRate> estimateFeeRate(
//     int blocks,
//     Blockchain blockchain,
//   ) async {
//     final feeRate = await blockchain.estimateFee(blocks);
//     return feeRate;
//   }

//   getInputOutPuts(
//     TxBuilderResult txBuilderResult,
//     Blockchain blockchain,
//   ) async {
//     final serializedPsbtTx = await txBuilderResult.psbt.jsonSerialize();
//     final jsonObj = json.decode(serializedPsbtTx);
//     final outputs = jsonObj["unsigned_tx"]["output"] as List;
//     final inputs = jsonObj["inputs"][0]["non_witness_utxo"]["output"] as List;
//     logger.d("=========Inputs=====");
//     for (var e in inputs) {
//       logger.d("amount: ${e["value"]}");
//       logger.d("script_pubkey: ${e["script_pubkey"]}");
//     }
//     logger.d("=========Outputs=====");
//     for (var e in outputs) {
//       logger.d("amount: ${e["value"]}");
//       logger.d("script_pubkey: ${e["script_pubkey"]}");
//     }
//   }

//   Future<Address> addressFromScript(type.Script script) async {
//     return await Address.fromScript(script, coinType.network);
//   }

//   sendBitcoin(Blockchain blockchain, Wallet aliceWallet, String addressStr,
//       int amount) async {
//     try {
//       final txBuilder = TxBuilder();
//       final address = await Address.create(address: addressStr);

//       final script = await address.scriptPubKey();
//       //   final feeRate = await estimateFeeRate(25, blockchain);
//       final txBuilderResult = await txBuilder
//           .addRecipient(script, amount)
//           .feeRate(1.0)
//           .finish(aliceWallet);
//       getInputOutPuts(txBuilderResult, blockchain);
//       final aliceSbt = await aliceWallet.sign(psbt: txBuilderResult.psbt);
//       final tx = await aliceSbt.extractTx();
//       Isolate.run(() async {
//         await RustLib.init(); // Need to init RustLib in Isolate
//         await blockchain.broadcast(tx);
//       });
//     } on Exception catch (e) {
//       e.toString();
//       rethrow;
//     }
//   }

//   Future<String> sendBitcoinWithAPI(
//     Blockchain blockchain,
//     Wallet aliceWallet,
//     String serverWalletID,
//     String serverAccountID,
//     TxBuilderResult txBuilderResult, {
//     String? emailAddressID,
//     String? encryptedLabel,
//     String? exchangeRateID,
//     String? transactionTime,
//     String? encryptedMessage,
//   }) async {
//     getInputOutPuts(txBuilderResult, blockchain);
//     final aliceSbt = await aliceWallet.sign(psbt: txBuilderResult.psbt);
//     bdk_helper.Transaction tx = await aliceSbt.extractTx();
//     String transactionID = await proton_api.broadcastRawTransaction(
//       signedTransactionHex: tx.toString(),
//       walletId: serverWalletID,
//       walletAccountId: serverAccountID,
//       label: encryptedLabel,
//       addressId: emailAddressID,
//       exchangeRateId: exchangeRateID,
//       transactionTime: transactionTime,
//       body: encryptedMessage,
//     );
//     return transactionID;
//   }
}
