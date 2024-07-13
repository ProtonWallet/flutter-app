import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/models/database/app.database.dart';
import 'package:wallet/models/wallet.model.dart';

Future<void> main() async {
  List? results;
  final AppDatabase appDatabase = AppDatabase();
  final DateTime now = DateTime.now();

  setUpAll(() async {
    databaseFactory = databaseFactoryFfi;
    await appDatabase.init(await AppDatabase.getInMemoryDatabase());
    await appDatabase.buildDatabase();
  });

  group('WalletDao', () {
    test('Insert case 1', () async {
      // Insert the data
      int id = await appDatabase.walletDao.insert(WalletModel(
        id: -1,
        userID: "server_userid_2",
        name: 'Wallet for Test 1',
        walletID: "test_wallet_id_1",
        mnemonic: Uint8List(0),
        passphrase: 0,
        publicKey: Uint8List(0),
        imported: WalletModel.createByProton,
        priority: WalletModel.primary,
        status: WalletModel.statusActive,
        type: WalletModel.typeOnChain,
        fingerprint: "12345678",
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        showWalletRecovery: 1,
      ));
      expect(id, 1);
      id = await appDatabase.walletDao.insert(WalletModel(
        id: -1,
        userID: "server_userid_2",
        name: 'Wallet for Test 2',
        mnemonic: Uint8List(0),
        passphrase: 1,
        publicKey: Uint8List(0),
        imported: WalletModel.createByProton,
        priority: WalletModel.primary,
        status: WalletModel.statusDisabled,
        type: WalletModel.typeOnChain,
        fingerprint: "22222222",
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        walletID: "test_wallet_id_2",
        showWalletRecovery: 0,
      ));
      expect(id, 2);
    });

    test('findAll case 1', () async {
      results = await appDatabase.walletDao.findAllByUserID("server_userid_2");
      // Verify that the data was inserted and retrieved correctly
      expect(results?.length, 2);
      expect(results?[0].id, 1);
      expect(results?[0].name, 'Wallet for Test 1');
      expect(results?[0].userID, 'server_userid_2');
      expect(results?[0].passphrase, 0);
      expect(results?[0].imported, WalletModel.createByProton);
      expect(results?[0].priority, WalletModel.primary);
      expect(results?[0].status, WalletModel.statusActive);
      expect(results?[0].type, WalletModel.typeOnChain);
      expect(results?[0].fingerprint, "12345678");
      expect(results?[0].showWalletRecovery, 1);
      expect(results?[0].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results?[0].modifyTime, now.millisecondsSinceEpoch ~/ 1000);

      expect(results?[1].id, 2);
      expect(results?[1].userID, "server_userid_2");
      expect(results?[1].name, 'Wallet for Test 2');
      expect(results?[1].passphrase, 1);
      expect(results?[1].imported, WalletModel.createByProton);
      expect(results?[1].priority, WalletModel.primary);
      expect(results?[1].status, WalletModel.statusDisabled);
      expect(results?[1].type, WalletModel.typeOnChain);
      expect(results?[1].fingerprint, "22222222");
      expect(results?[1].showWalletRecovery, 0);
      expect(results?[1].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results?[1].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('findByID case 1', () async {
      // findByID
      final WalletModel walletModel = await appDatabase.walletDao.findById(2);
      expect(walletModel.id, 2);
      expect(walletModel.userID, "server_userid_2");
      expect(walletModel.name, 'Wallet for Test 2');
      expect(walletModel.passphrase, 1);
      expect(walletModel.imported, WalletModel.createByProton);
      expect(walletModel.priority, WalletModel.primary);
      expect(walletModel.status, WalletModel.statusDisabled);
      expect(walletModel.type, WalletModel.typeOnChain);
      expect(walletModel.fingerprint, "22222222");
      expect(walletModel.createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(walletModel.modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('delete case 1', () async {
      // Delete record
      await appDatabase.walletDao.delete(1);

      // Verify new result after delete
      results = await appDatabase.walletDao.findAllByUserID("server_userid_2");
      // Verify that the data was inserted and retrieved correctly
      expect(results?.length, 1);
      expect(results?[0].id, 2);
      expect(results?[0].userID, "server_userid_2");
      expect(results?[0].name, 'Wallet for Test 2');
      expect(results?[0].passphrase, 1);
      expect(results?[0].imported, WalletModel.createByProton);
      expect(results?[0].priority, WalletModel.primary);
      expect(results?[0].status, WalletModel.statusDisabled);
      expect(results?[0].type, WalletModel.typeOnChain);
      expect(results?[0].fingerprint, "22222222");
      expect(results?[0].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results?[0].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('update case 1', () async {
      await appDatabase.walletDao.update(WalletModel(
        id: 2,
        userID: "server_userid_33",
        name: 'Wallet for Test Updated',
        mnemonic: Uint8List(0),
        passphrase: 0,
        publicKey: Uint8List(0),
        imported: WalletModel.createByProton,
        priority: WalletModel.primary,
        status: WalletModel.statusDisabled,
        type: WalletModel.typeOnChain,
        fingerprint: null,
        createTime: now.millisecondsSinceEpoch ~/ 1000 + 9487949,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000 - 87653,
        walletID: "",
        showWalletRecovery: 0,
      ));
      final WalletModel walletModel = await appDatabase.walletDao.findById(2);
      expect(walletModel.id, 2);
      expect(walletModel.userID, "server_userid_33");
      expect(walletModel.name, 'Wallet for Test Updated');
      expect(walletModel.passphrase, 0);
      expect(walletModel.imported, WalletModel.createByProton);
      expect(walletModel.priority, WalletModel.primary);
      expect(walletModel.status, WalletModel.statusDisabled);
      expect(walletModel.type, WalletModel.typeOnChain);
      expect(walletModel.fingerprint, null);
      expect(walletModel.showWalletRecovery, 0);
      expect(
          walletModel.createTime, now.millisecondsSinceEpoch ~/ 1000 + 9487949);
      expect(
          walletModel.modifyTime, now.millisecondsSinceEpoch ~/ 1000 - 87653);
    });
  });
}
