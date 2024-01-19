import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/database/app.database.dart';

Future<void> main() async {
  AppDatabase appDatabase = AppDatabase();
  DateTime now = DateTime.now();

  setUpAll(() async {
    await appDatabase.init(await AppDatabase.getInMemoryDatabase());
    await appDatabase.buildDatabase();
  });

  group('AccountDao', () {
    test('Insert case 1', () async {
      // Insert the data
      int id = await appDatabase.accountDao.insert(AccountModel(
          id: null,
          walletID: 1,
          derivationPath: "m/84'/1'/0'/0",
          label: Uint8List(0),
          scriptType: ScriptType.legacy.index,
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000));
      expect(id, 1);
      id = await appDatabase.accountDao.insert(AccountModel(
          id: null,
          walletID: 12,
          derivationPath: "m/84'/1'/0'/0",
          label: Uint8List(0),
          scriptType: ScriptType.nativeSegWit.index,
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000));
      expect(id, 2);

      id = await appDatabase.accountDao.insert(AccountModel(
          id: null,
          walletID: 12,
          derivationPath: "m/84'/1'/168'/0",
          label: Uint8List(0),
          scriptType: ScriptType.nestedSegWit.index,
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000));
      expect(id, 3);
    });

    test('getAccountCount case 1', () async {
      int count = await appDatabase.accountDao.getAccountCount(12);
      expect(count, 2);
      count = await appDatabase.accountDao.getAccountCount(1);
      expect(count, 1);
      count = await appDatabase.accountDao.getAccountCount(11);
      expect(count, 0);
    });

    test('findAll case 1', () async {
      List results = await appDatabase.accountDao.findAll();
      // Verify that the data was inserted and retrieved correctly
      expect(results.length, 3);
      expect(results[0].id, 1);
      expect(results[0].walletID, 1);
      expect(results[0].derivationPath, "m/84'/1'/0'/0");
      expect(results[0].scriptType, ScriptType.legacy.index);
      expect(results[0].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[0].modifyTime, now.millisecondsSinceEpoch ~/ 1000);

      expect(results[1].id, 2);
      expect(results[1].walletID, 12);
      expect(results[1].derivationPath, "m/84'/1'/0'/0");
      expect(results[1].scriptType, ScriptType.nativeSegWit.index);
      expect(results[1].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[1].modifyTime, now.millisecondsSinceEpoch ~/ 1000);

      expect(results[2].id, 3);
      expect(results[2].walletID, 12);
      expect(results[2].derivationPath, "m/84'/1'/168'/0");
      expect(results[2].scriptType, ScriptType.nestedSegWit.index);
      expect(results[2].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[2].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('findByID case 1', () async {
      // findByID
      AccountModel accountModel = await appDatabase.accountDao.findById(3);
      expect(accountModel.id, 3);
      expect(accountModel.walletID, 12);
      expect(accountModel.derivationPath, "m/84'/1'/168'/0");
      expect(accountModel.scriptType, ScriptType.nestedSegWit.index);
      expect(accountModel.createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(accountModel.modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('findAllByWalletID case 1', () async {
      // findByID
      List results = await appDatabase.accountDao.findAllByWalletID(12);
      expect(results.length, 2);

      results = await appDatabase.accountDao.findAllByWalletID(1);
      expect(results.length, 1);

      results = await appDatabase.accountDao.findAllByWalletID(11);
      expect(results.length, 0);
    });

    test('delete case 1', () async {
      // Delete record
      await appDatabase.accountDao.delete(2);

      // Verify new result after delete
      List results = await appDatabase.accountDao.findAll();
      // Verify that the data was inserted and retrieved correctly
      expect(results[0].id, 1);
      expect(results[0].walletID, 1);
      expect(results[0].derivationPath, "m/84'/1'/0'/0");
      expect(results[0].scriptType, ScriptType.legacy.index);
      expect(results[0].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[0].modifyTime, now.millisecondsSinceEpoch ~/ 1000);

      expect(results[1].id, 3);
      expect(results[1].walletID, 12);
      expect(results[1].derivationPath, "m/84'/1'/168'/0");
      expect(results[1].scriptType, ScriptType.nestedSegWit.index);
      expect(results[1].createTime, now.millisecondsSinceEpoch ~/ 1000);
      expect(results[1].modifyTime, now.millisecondsSinceEpoch ~/ 1000);
    });

    test('update case 1', () async {
      await appDatabase.accountDao.update(AccountModel(
          id: 3,
          walletID: 112,
          derivationPath: "m/84'/1'/12'/0",
          label: Uint8List(0),
          scriptType: ScriptType.taproot.index,
          createTime: now.millisecondsSinceEpoch ~/ 1000 + 1234567,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000 + 55688));
      AccountModel accountModel = await appDatabase.accountDao.findById(3);
      expect(accountModel.id, 3);
      expect(accountModel.walletID, 112);
      expect(accountModel.derivationPath, "m/84'/1'/12'/0");
      expect(accountModel.scriptType, ScriptType.taproot.index);
      expect(accountModel.createTime,
          now.millisecondsSinceEpoch ~/ 1000 + 1234567);
      expect(
          accountModel.modifyTime, now.millisecondsSinceEpoch ~/ 1000 + 55688);
    });
  });
}
