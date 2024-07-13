import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.dao.dart';
import 'package:wallet/models/database/wallet.database.dart';
import 'wallet.model.dart';

abstract class WalletDao extends WalletDatabase implements BaseDao {
  WalletDao(super.db, super.tableName);

  Future<int> counts(String userID);

  Future<WalletModel?> getFirstPriorityWallet(String userID);

  Future<List<WalletModel>> findAllByUserID(String userID);
}

class WalletDaoImpl extends WalletDao {
  WalletDaoImpl(Database db) : super(db, 'wallet');

  @override
  Future<WalletModel?> findById(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<WalletModel?> findByServerID(String serverID) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'walletID = ?',
      whereArgs: [serverID],
    );
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<WalletModel?> getFirstPriorityWallet(String userID) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'status = ? AND userID = ?',
        whereArgs: [WalletModel.statusActive, userID],
        orderBy: 'priority asc',
        limit: 1);
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<int> insert(item) async {
    final int id = await db.insert(
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
  Future<int> counts(String userID) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.length;
  }

  @override
  Future<void> delete(int id) async {
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteByServerID(String walletID) async {
    await db.delete(
      tableName,
      where: 'walletID = ?',
      whereArgs: [walletID],
    );
  }

  @override
  Future<List<WalletModel>> findAllByUserID(String userID) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'userID = ?',
      whereArgs: [userID],
      orderBy: 'priority ASC',
    );
    return List.generate(
      maps.length,
      (index) => WalletModel.fromMap(maps[index]),
    );
  }
}
