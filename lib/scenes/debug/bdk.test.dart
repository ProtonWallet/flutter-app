import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
// import 'package:wallet/generated/bridge_definitions.dart';
// import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/logger.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet/rust/blockchain.dart';

import 'dart:async';

import 'package:wallet/rust/types.dart';
import 'package:wallet/rust/wallet.dart';

class BdkLibrary {
  Future<Mnemonic> createMnemonic() async {
    final res = await Mnemonic.create(WordCount.words12);
    return res;
  }

  Future<Descriptor> createDescriptor(Mnemonic mnemonic) async {
    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: Network.testnet,
      mnemonic: mnemonic,
    );
    final descriptor = await Descriptor.newBip84(
        secretKey: descriptorSecretKey,
        network: Network.testnet,
        keychain: KeychainKind.External);
    return descriptor;
  }

  // get descriptor with given mnemonic and derivationPath
  Future<Descriptor> createDerivedDescriptor(
      Mnemonic mnemonic, DerivationPath derivationPath) async {
    int purpose =
        int.parse(derivationPath.toString().split('/')[1].split("'")[0]);

    DescriptorSecretKey descriptorSecretKey = await DescriptorSecretKey.create(
        network: Network.testnet, mnemonic: mnemonic);

    DescriptorSecretKey descriptorPrivateKey =
        await descriptorSecretKey.derive(derivationPath);
    if (purpose == 44) {
      // BIP-0044
      Descriptor descriptor = await Descriptor.create(
        descriptor: "pkh(${descriptorPrivateKey.toString()})",
        network: Network.testnet,
      );
      return descriptor;
    } else {
      Descriptor descriptor = await Descriptor.create(
        descriptor: "wpkh(${descriptorPrivateKey.toString()})",
        network: Network.testnet,
      );
      return descriptor;
    }
  }

  Future<Blockchain> initializeBlockchain(bool isElectrumBlockchain) async {
    if (Platform.isAndroid) {
      final blockchain = await Blockchain.createElectrum(
          config: const ElectrumConfig(
              stopGap: 10,
              timeout: 5,
              retry: 5,
              url: "ssl://electrum.blockstream.info:60002",
              validateDomain: true));
      return blockchain;
    } else {
      final blockchain = await Blockchain.create(
          config: const EsploraConfig(
              baseUrl: 'https://blockstream.info/testnet/api', stopGap: 10));
      return blockchain;
    }
    //   final blockchain = await Blockchain.create(
    //       config: const BlockchainConfig.electrum(
    //           config: ElectrumConfig(
    //               stopGap: 10,
    //               timeout: 5,
    //               retry: 5,
    //               url: "ssl://electrum.blockstream.info:60002",
    //               validateDomain: true)));
  }

  Future<Wallet> restoreWallet(Descriptor descriptor,
      {String databaseName = "test_database"}) async {
    DatabaseConfig config;
    if (Platform.isWindows) {
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
        network: Network.testnet,
        databaseConfig: config);
    return wallet;
  }

  Future<Wallet> restoreWalletInMemory(Descriptor descriptor) async {
    final wallet = await Wallet.create(
        descriptor: descriptor,
        network: Network.Testnet,
        databaseConfig: const DatabaseConfig.memory());
    return wallet;
  }

  Future<void> sync(Blockchain blockchain, Wallet aliceWallet) async {
    try {
      await Isolate.run(() async => {await aliceWallet.sync(blockchain)});
    } on FormatException catch (e) {
      logger.d(e.message);
    }
  }

  Future<AddressInfo> getAddress(Wallet aliceWallet, {int? addressIndex}) async {
    AddressInfo addressInfo;
    if (addressIndex != null){
      addressInfo =
      await aliceWallet.getAddress(addressIndex: AddressIndex.peek(index: addressIndex));
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

  Future<Balance> getBalance(Wallet aliceWallet) async {
    final res = await aliceWallet.getBalance();
    return res;
  }

  Future<List<LocalUtxo>> listUnspend(Wallet aliceWallet) async {
    final res = await aliceWallet.listUnspent();
    return res;
  }

  // Future<FeeRate> estimateFeeRate(
  //   int blocks,
  //   Blockchain blockchain,
  // ) async {
  //   final feeRate = await blockchain.estimateFee(blocks);
  //   return feeRate;
  // }

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
    // try {
    //   final txBuilder = TxBuilder();
    //   final address = await Address.create(address: addressStr);

    //   final script = await address.scriptPubKey();
    //   final feeRate = await estimateFeeRate(25, blockchain);
    //   final txBuilderResult = await txBuilder
    //       .addRecipient(script, amount)
    //       .feeRate(feeRate.asSatPerVb())
    //       .finish(aliceWallet);
    //   getInputOutPuts(txBuilderResult, blockchain);
    //   final aliceSbt = await aliceWallet.sign(psbt: txBuilderResult.psbt);
    //   final tx = await aliceSbt.extractTx();
    //   Isolate.run(() async => {await blockchain.broadcast(tx)});
    // } on Exception catch (_) {
    //   rethrow;
    // }
  }
}
