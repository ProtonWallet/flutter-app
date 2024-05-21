import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/bdk/helper.dart' as bdk_helper;
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/logger.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet/rust/bdk/blockchain.dart';
import 'package:wallet/rust/frb_generated.dart';

import 'dart:async';

import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/rust/bdk/wallet.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

class BdkLibrary {
  CoinType coinType;

  BdkLibrary({required this.coinType});

  Future<Mnemonic> createMnemonic() async {
    final res = await Mnemonic.create(WordCount.words12);
    return res;
  }

  Future<Descriptor> createDescriptor(Mnemonic mnemonic) async {
    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: coinType.network,
      mnemonic: mnemonic,
    );
    final descriptor = await Descriptor.newBip84(
        secretKey: descriptorSecretKey,
        network: coinType.network,
        keychain: KeychainKind.External);
    return descriptor;
  }

  // get descriptor with given mnemonic and derivationPath
  Future<Descriptor> createDerivedDescriptor(
      Mnemonic mnemonic, DerivationPath derivationPath,
      {String? passphrase}) async {
    int purpose =
        int.parse(derivationPath.toString().split('/')[1].split("'")[0]);
    DescriptorSecretKey descriptorSecretKey;
    if (passphrase != null && passphrase != "") {
      descriptorSecretKey = await DescriptorSecretKey.create(
          network: coinType.network, mnemonic: mnemonic, password: passphrase);
    } else {
      descriptorSecretKey = await DescriptorSecretKey.create(
          network: coinType.network, mnemonic: mnemonic);
    }

    DescriptorSecretKey descriptorPrivateKey =
        await descriptorSecretKey.derive(derivationPath);
    if (purpose == 44) {
      // BIP-0044
      Descriptor descriptor = await Descriptor.create(
        descriptor: "pkh(${descriptorPrivateKey.toString()})",
        network: coinType.network,
      );
      return descriptor;
    } else {
      Descriptor descriptor = await Descriptor.create(
        descriptor: "wpkh(${descriptorPrivateKey.toString()})",
        network: coinType.network,
      );
      return descriptor;
    }
  }

  Future<Blockchain> initializeBlockchain(bool isElectrumBlockchain) async {
    final blockchain = await Blockchain.create(
        config: EsploraConfig(
            baseUrl: '${appConfig.esploraBaseUrl}api', stopGap: 10));
    return blockchain;
  }

  // TODO:: before new_wallet need to check if network changed. if yes need to delete the wallet and create a new one
  Future<Wallet> restoreWallet(Descriptor descriptor,
      {String databaseName = "test_database"}) async {
    DatabaseConfig config;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      String path = join(appDocumentsDir.path, "databases", "$databaseName.db");
      //Create db, db need to be initialize to avoid error
      var db = await databaseFactory.openDatabase(
        path,
      );
      await db.close();
      config = DatabaseConfig.sqlite(config: SqliteDbConfiguration(path: path));
    } else {
      var path = await getDatabasesPath();
      config = DatabaseConfig.sqlite(
          config: SqliteDbConfiguration(path: join(path, '$databaseName.db')));
    }
    final wallet = await Wallet.create(
        descriptor: descriptor,
        network: coinType.network,
        databaseConfig: config);
    return wallet;
  }

  Future<void> clearLocalCache() async {
    String? path;
    if (Platform.isWindows || Platform.isLinux) {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      path = join(appDocumentsDir.path, "databases");
    } else {
      path = await getDatabasesPath();
    }

    final dir = Directory(path);
    if (await dir.exists()) {
      List<FileSystemEntity> entities = dir.listSync();
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          String fileName = basename(entity.path);
          if ((fileName.endsWith("true.db") || fileName.endsWith("false.db")) &&
              fileName.contains("_m_")) {
            // TODO:: update with regular expression
            logger.i("removing bdk db: ${entity.path}");
            entity.deleteSync();
          }
        }
      }
    }
  }

  Future<Wallet> restoreWalletInMemory(Descriptor descriptor) async {
    final wallet = await Wallet.create(
        descriptor: descriptor,
        network: coinType.network,
        databaseConfig: const DatabaseConfig.memory());
    return wallet;
  }

  Future<void> syncWallet(Blockchain blockchain, Wallet aliceWallet) async {
    try {
      // await aliceWallet.syncWallet(blockchain);
      await Isolate.run(() async => {
            await RustLib.init(),
            await aliceWallet.syncWallet(blockchain),
            RustLib.dispose()
          });
    } on FormatException catch (e) {
      logger.d(e.message);
    }
  }

  Future<AddressInfo> getAddress(Wallet aliceWallet,
      {int? addressIndex}) async {
    AddressInfo addressInfo;
    if (addressIndex != null) {
      addressInfo = await aliceWallet.getAddress(
          addressIndex: AddressIndex.peek(index: addressIndex));
    } else {
      addressInfo =
          await aliceWallet.getAddress(addressIndex: const AddressIndex());
    }
    return addressInfo;
  }

  Future<Input> getPsbtInput(
      Wallet aliceWallet, LocalUtxo utxo, bool onlyWitnessUtxo) async {
    final input = await aliceWallet.getPsbtInput(
        utxo: utxo, onlyWitnessUtxo: onlyWitnessUtxo);
    return input;
  }

  Future<List<TransactionDetails>> getUnConfirmedTransactions(
      Wallet aliceWallet) async {
    List<TransactionDetails> unConfirmed = [];
    final res = await aliceWallet.listTransactions(true);
    for (var e in res) {
      if (e.confirmationTime == null) unConfirmed.add(e);
    }
    return unConfirmed;
  }

  Future<List<TransactionDetails>> getConfirmedTransactions(
      Wallet aliceWallet) async {
    List<TransactionDetails> confirmed = [];
    final res = await aliceWallet.listTransactions(true);

    for (var e in res) {
      if (e.confirmationTime != null) confirmed.add(e);
    }
    return confirmed;
  }

  Future<List<TransactionDetails>> getAllTransactions(
      Wallet aliceWallet) async {
    return await aliceWallet.listTransactions(true);
  }

  Future<Balance> getBalance(Wallet aliceWallet) async {
    final res = await aliceWallet.getBalance();
    return res;
  }

  Future<List<LocalUtxo>> listUnspend(Wallet aliceWallet) async {
    final res = await aliceWallet.listUnspent();
    return res;
  }

  Future<FeeRate> estimateFeeRate(
    int blocks,
    Blockchain blockchain,
  ) async {
    final feeRate = await blockchain.estimateFee(blocks);
    return feeRate;
  }

  getInputOutPuts(
    TxBuilderResult txBuilderResult,
    Blockchain blockchain,
  ) async {
    final serializedPsbtTx = await txBuilderResult.psbt.jsonSerialize();
    final jsonObj = json.decode(serializedPsbtTx);
    final outputs = jsonObj["unsigned_tx"]["output"] as List;
    final inputs = jsonObj["inputs"][0]["non_witness_utxo"]["output"] as List;
    logger.d("=========Inputs=====");
    for (var e in inputs) {
      logger.d("amount: ${e["value"]}");
      logger.d("script_pubkey: ${e["script_pubkey"]}");
    }
    logger.d("=========Outputs=====");
    for (var e in outputs) {
      logger.d("amount: ${e["value"]}");
      logger.d("script_pubkey: ${e["script_pubkey"]}");
    }
  }

  sendBitcoin(Blockchain blockchain, Wallet aliceWallet, String addressStr,
      int amount) async {
    try {
      final txBuilder = TxBuilder();
      final address = await Address.create(address: addressStr);

      final script = await address.scriptPubKey();
      //   final feeRate = await estimateFeeRate(25, blockchain);
      final txBuilderResult = await txBuilder
          .addRecipient(script, amount)
          .feeRate(1.0)
          .finish(aliceWallet);
      getInputOutPuts(txBuilderResult, blockchain);
      final aliceSbt = await aliceWallet.sign(psbt: txBuilderResult.psbt);
      final tx = await aliceSbt.extractTx();
      Isolate.run(() async {
        await RustLib.init(); // Need to init RustLib in Isolate
        await blockchain.broadcast(tx);
      });
    } on Exception catch (e) {
      e.toString();
      rethrow;
    }
  }

  Future<String> sendBitcoinWithAPI(
    Blockchain blockchain,
    Wallet aliceWallet,
    String serverWalletID,
    String serverAccountID,
    TxBuilderResult txBuilderResult, {
    String? emailAddressID,
    String? encryptedLabel,
    String? exchangeRateID,
    String? transactionTime,
    String? encryptedMessage,
  }) async {
    getInputOutPuts(txBuilderResult, blockchain);
    final aliceSbt = await aliceWallet.sign(psbt: txBuilderResult.psbt);
    bdk_helper.Transaction tx = await aliceSbt.extractTx();
    String transactionID = await proton_api.broadcastRawTransaction(
      signedTransactionHex: tx.toString(),
      walletId: serverWalletID,
      walletAccountId: serverAccountID,
      label: encryptedLabel,
      addressId: emailAddressID,
      exchangeRateId: exchangeRateID,
      transactionTime: transactionTime,
      body: encryptedMessage,
    );
    return transactionID;
  }
}
