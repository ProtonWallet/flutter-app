import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/account.database.dart';
import 'package:wallet/models/database/base.dao.dart';
import 'account.model.dart';

abstract class AccountDao extends AccountDatabase implements BaseDao {
  AccountDao(super.db, super.tableName);

  Future findByDerivationPath(String walletID, String derivationPath);

  Future<List<AccountModel>> findAllByWalletID(String walletID);

  Future<int> getAccountCount(String walletID);

  Future deleteAccountsNotInServers(
    String walletID,
    List<String> serverAccountIDs,
  );

  Future deleteAccountsByWalletID(String walletID);

  Future<AccountModel?> findDefaultAccountByWalletID(String walletID);
}

class AccountDaoImpl extends AccountDao {
  AccountDaoImpl(Database db) : super(db, 'account');

  @override
  @Deprecated("Use deleteBy(serverID) instead, delete account by server id")
  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAccountsByWalletID(String walletID) async {
    await db.delete(tableName, where: 'walletID = ?', whereArgs: [walletID]);
  }

  @override
  Future findById(int id) async {
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<AccountModel?> findByDerivationPath(
    String walletID,
    String derivationPath,
  ) async {
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'walletID = ? AND derivationPath = ?',
      whereArgs: [walletID, derivationPath],
    );
    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<int> insert(item) async {
    int id = await db.insert(
      tableName,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  @override
  Future<void> update(item) async {
    await db.update(
      tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<int> getAccountCount(String walletID) async {
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'walletID = ?', whereArgs: [walletID]);
    return maps.length;
  }

  @override
  Future<List<AccountModel>> findAllByWalletID(String walletID) async {
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'walletID = ?',
      whereArgs: [walletID],
    );
    List<AccountModel> accounts = List.generate(
      maps.length,
      (index) => AccountModel.fromMap(maps[index]),
    );
    return accounts;
  }

  @override
  Future<AccountModel?> findDefaultAccountByWalletID(String walletID) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'walletID = ?',
        whereArgs: [walletID],
        orderBy: 'derivationPath asc');
    AccountModel? accountModel;
    if (maps.isNotEmpty) {
      accountModel = AccountModel.fromMap(maps.first);
    }
    return accountModel;
  }

  @override
  Future deleteAccountsNotInServers(
    String walletID,
    List<String> serverAccountIDs,
  ) async {
    String notIn = serverAccountIDs.join('","');
    String sql =
        'DELETE FROM $tableName WHERE walletID = $walletID AND accountID NOT IN ("$notIn")';
    await db.rawDelete(sql);
  }

  @override
  Future<void> deleteByServerID(String accountID) async {
    await db.delete(
      tableName,
      where: 'accountID = ?',
      whereArgs: [accountID],
    );
  }

  @override
  Future<AccountModel?> findByServerID(String accountID) async {
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountID = ?',
      whereArgs: [accountID],
    );
    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    } else {
      return null;
    }
  }
}
