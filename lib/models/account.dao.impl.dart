import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/base.dao.dart';
import 'account.model.dart';

abstract class AccountDao extends BaseDao {
  AccountDao(super.db, super.tableName);

  Future findByDerivationPath(int walletID, String derivationPath);

  Future findAllByWalletID(int walletID);

  Future findByServerAccountID(String serverAccountID);

  Future<int> getAccountCount(int walletID);

  Future deleteAccountsNotInServers(int walletID, List<String> serverAccountIDs);

  Future deleteAccountsByWalletID(int walletID);
}

class AccountDaoImpl extends AccountDao {
  AccountDaoImpl(Database db) : super(db, 'account');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteAccountsByWalletID(int walletID) async {
    await db.delete(tableName, where: 'walletID = ?', whereArgs: [walletID]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => AccountModel.fromMap(maps[index]));
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
  Future findByServerAccountID(String serverAccountID) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'serverAccountID = ?', whereArgs: [serverAccountID]);
    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future findByDerivationPath(int walletID, String derivationPath) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'walletID = ? AND derivationPath = ?',
        whereArgs: [walletID, derivationPath]);
    if (maps.isNotEmpty) {
      return AccountModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<int> insert(item) async {
    int id = await db.insert(tableName, item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  @override
  Future<void> update(item) async {
    await db
        .update(tableName, item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  @override
  Future<int> getAccountCount(int walletID) async {
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'walletID = ?', whereArgs: [walletID]);
    return maps.length;
  }

  @override
  Future<List> findAllByWalletID(int walletID) async {
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'walletID = ?', whereArgs: [walletID]);
    return List.generate(
        maps.length, (index) => AccountModel.fromMap(maps[index]));
  }

  @override
  Future deleteAccountsNotInServers(int walletID, List<String> serverAccountIDs) async {
    String notIn = serverAccountIDs.join('","');
    String sql = 'DELETE FROM $tableName WHERE walletID = $walletID AND serverAccountID NOT IN ("$notIn")';
    await db.rawDelete(sql);
  }
}
