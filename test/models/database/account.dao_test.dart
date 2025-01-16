import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/database/app.database.dart';

Future<void> main() async {
  final AppDatabase appDatabase = AppDatabase();
  final DateTime now = DateTime.now();

  setUpAll(() async {
    databaseFactory = databaseFactoryFfi;
    await appDatabase.init(await AppDatabase.getInMemoryDatabase());
    await appDatabase.buildDatabase();
  });

  group('AccountDao', () {
    test('Insert case 1', () async {
      // Insert the data
      int id = await appDatabase.accountDao.insert(AccountModel(
        id: -1,
        walletID: "server_walletid_1",
        derivationPath: "m/84'/1'/0'/0",
        label: Uint8List(0),
        fiatCurrency: "USD",
        scriptType: ScriptTypeInfo.legacy.index,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        accountID: "",
        priority: 1,
        poolSize: 10,
        lastUsedIndex: 10,
        stopGap: 20,
      ));
      expect(id, 1);
      id = await appDatabase.accountDao.insert(AccountModel(
        id: -1,
        walletID: "server_walletid_12",
        derivationPath: "m/84'/1'/0'/0",
        label: Uint8List(0),
        fiatCurrency: "USD",
        scriptType: ScriptTypeInfo.nativeSegWit.index,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        accountID: "",
        priority: 2,
        poolSize: 20,
        lastUsedIndex: 20,
        stopGap: 456,
      ));
      expect(id, 2);

      id = await appDatabase.accountDao.insert(AccountModel(
        id: -1,
        walletID: "server_walletid_12",
        derivationPath: "m/84'/1'/168'/0",
        label: Uint8List(1),
        fiatCurrency: "CHF",
        scriptType: ScriptTypeInfo.nestedSegWit.index,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        accountID: "",
        priority: 3,
        poolSize: 30,
        lastUsedIndex: 30,
        stopGap: 20,
      ));
      expect(id, 3);

      id = await appDatabase.accountDao.insert(AccountModel(
        id: -1,
        walletID: "server_walletid_12",
        derivationPath: "m/84'/1'/168'/2",
        label: Uint8List(2),
        fiatCurrency: "CHF",
        scriptType: ScriptTypeInfo.nestedSegWit.index,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        accountID: "",
        priority: 4,
        poolSize: 40,
        lastUsedIndex: 40,
        stopGap: 20,
      ));
      expect(id, 4);

      // this should fail
      id = await appDatabase.accountDao.insert(AccountModel(
        id: -1,
        walletID: "server_walletid_12",
        derivationPath: "m/84'/1'/168'/2",
        label: Uint8List(3),
        fiatCurrency: "USD",
        scriptType: ScriptTypeInfo.nestedSegWit.index,
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        accountID: "",
        priority: 5,
        poolSize: 50,
        lastUsedIndex: 50,
        stopGap: 20,
      ));
      expect(id, 5);
    });

    test('getAccountCount case 1', () async {
      int count =
          await appDatabase.accountDao.getAccountCount("server_walletid_12");
      expect(count, 3);
      count = await appDatabase.accountDao.getAccountCount("server_walletid_1");
      expect(count, 1);
      count =
          await appDatabase.accountDao.getAccountCount("server_walletid_11");
      expect(count, 0);
    });

    test('findAll case 1', () async {
      const walletID = "server_walletid_12";
      var results = await appDatabase.accountDao.findAllByWalletID(walletID);
      // Verify that the data was inserted and retrieved correctly
      expect(results.length, 3);
      expect(results[0].id, 2);
      expect(results[0].priority, 2);
      expect(results[0].lastUsedIndex, 20);
      expect(results[0].poolSize, 20);
      expect(results[0].walletID, walletID);
      expect(results[0].derivationPath, "m/84'/1'/0'/0");
      expect(results[0].fiatCurrency, "USD");
      expect(results[0].scriptType, ScriptTypeInfo.nativeSegWit.index);
      expect(results[0].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[0].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[0].stopGap, 456);

      expect(results[1].id, 3);
      expect(results[1].priority, 3);
      expect(results[1].lastUsedIndex, 30);
      expect(results[1].poolSize, 30);
      expect(results[1].walletID, walletID);
      expect(results[1].derivationPath, "m/84'/1'/168'/0");
      expect(results[1].fiatCurrency, "CHF");
      expect(results[1].scriptType, ScriptTypeInfo.nestedSegWit.index);
      expect(results[1].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[1].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[1].stopGap, 20);

      expect(results[2].id, 5);
      expect(results[2].priority, 5);
      expect(results[2].lastUsedIndex, 50);
      expect(results[2].poolSize, 50);
      expect(results[2].walletID, walletID);
      expect(results[2].derivationPath, "m/84'/1'/168'/2");
      expect(results[2].label, Uint8List(3));
      expect(results[2].fiatCurrency, "USD");
      expect(results[2].scriptType, ScriptTypeInfo.nestedSegWit.index);
      expect(results[2].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[2].modifyTime, now.millisecondsSinceEpoch ~/ 1000);

      results =
          await appDatabase.accountDao.findAllByWalletID("server_walletid_1");
      expect(results.length, 1);
      expect(results[0].id, 1);
      expect(results[0].priority, 1);
      expect(results[0].lastUsedIndex, 10);
      expect(results[0].poolSize, 10);
      expect(results[0].walletID, "server_walletid_1");
      expect(results[0].label, Uint8List(0));
      expect(results[0].derivationPath, "m/84'/1'/0'/0");
      expect(results[0].scriptType, ScriptTypeInfo.legacy.index);
      expect(results[0].fiatCurrency, "USD");
      expect(results[0].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[0].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('findByID case 1', () async {
      // findByID
      final AccountModel accountModel =
          await appDatabase.accountDao.findById(3);
      expect(accountModel.id, 3);
      expect(accountModel.priority, 3);
      expect(accountModel.lastUsedIndex, 30);
      expect(accountModel.poolSize, 30);
      expect(accountModel.walletID, "server_walletid_12");
      expect(accountModel.derivationPath, "m/84'/1'/168'/0");
      expect(accountModel.fiatCurrency, "CHF");
      expect(accountModel.scriptType, ScriptTypeInfo.nestedSegWit.index);
      expect(accountModel.createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(accountModel.modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('findAllByWalletID case 1', () async {
      // findByID
      List results =
          await appDatabase.accountDao.findAllByWalletID("server_walletid_12");
      expect(results.length, 3);

      results =
          await appDatabase.accountDao.findAllByWalletID("server_walletid_1");
      expect(results.length, 1);

      results =
          await appDatabase.accountDao.findAllByWalletID("server_walletid_11");
      expect(results.length, 0);
    });

    test('delete case 1', () async {
      // Delete record
      await appDatabase.accountDao.delete(2);
      const walletID = "server_walletid_12";

      // Verify new result after delete
      final List results =
          await appDatabase.accountDao.findAllByWalletID(walletID);
      // Verify that the data was inserted and retrieved correctly
      expect(results[0].id, 3);
      expect(results[0].priority, 3);
      expect(results[0].lastUsedIndex, 30);
      expect(results[0].poolSize, 30);
      expect(results[0].walletID, walletID);
      expect(results[0].derivationPath, "m/84'/1'/168'/0");
      expect(results[0].fiatCurrency, "CHF");
      expect(results[0].scriptType, ScriptTypeInfo.nestedSegWit.index);
      expect(results[0].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[0].modifyTime, now.millisecondsSinceEpoch ~/ 1000);

      expect(results[1].id, 5);
      expect(results[1].priority, 5);
      expect(results[1].lastUsedIndex, 50);
      expect(results[1].poolSize, 50);
      expect(results[1].walletID, walletID);
      expect(results[1].derivationPath, "m/84'/1'/168'/2");
      expect(results[1].label, Uint8List(3));
      expect(results[1].fiatCurrency, "USD");
      expect(results[1].scriptType, ScriptTypeInfo.nestedSegWit.index);
      expect(results[1].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[1].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('update case 1', () async {
      await appDatabase.accountDao.update(AccountModel(
        id: 3,
        walletID: "server_id_112",
        derivationPath: "m/84'/1'/12'/0",
        label: Uint8List(0),
        fiatCurrency: "USD",
        scriptType: ScriptTypeInfo.taproot.index,
        createTime: now.millisecondsSinceEpoch ~/ 1000 + 1234567,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000 + 55688,
        accountID: "",
        priority: 12,
        poolSize: 13,
        lastUsedIndex: 13,
        stopGap: 123,
      ));
      final AccountModel accountModel =
          await appDatabase.accountDao.findById(3);
      expect(accountModel.id, 3);
      expect(accountModel.walletID, "server_id_112");
      expect(accountModel.derivationPath, "m/84'/1'/12'/0");
      expect(accountModel.scriptType, ScriptTypeInfo.taproot.index);
      expect(accountModel.createTime,
          now.millisecondsSinceEpoch ~/ 1000 + 1234567);
      expect(
          accountModel.modifyTime, now.millisecondsSinceEpoch ~/ 1000 + 55688);
      expect(accountModel.priority, 12);
      expect(accountModel.lastUsedIndex, 13);
      expect(accountModel.poolSize, 13);
      expect(accountModel.stopGap, 123);
    });
  });
}
