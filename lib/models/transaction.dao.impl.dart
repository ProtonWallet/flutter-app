import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.dao.dart';
import 'package:wallet/models/database/transaction.database.dart';
import 'package:wallet/models/transaction.model.dart';

abstract class TransactionDao extends TransactionDatabase implements BaseDao {
  TransactionDao(super.db, super.tableName);

  Future<void> insertOrUpdate(TransactionModel transactionModel);

  Future<List<TransactionModel>> findAllByServerAccountID(
    String serverAccountID,
  );

  Future<TransactionModel?> find(
    Uint8List externalTransactionID,
    String serverWalletID,
    String serverAccountID,
  );

  Future<List> findAll();

  @override
  Future<TransactionModel?> findByServerID(String serverID);
}

class TransactionDaoImpl extends TransactionDao {
  TransactionDaoImpl(Database db) : super(db, 'walletTransaction');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => TransactionModel.fromMap(maps[index]));
  }

  @override
  Future findById(int id) async {
    final List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<int> insert(item) async {
    int id = 0;
    if (item is TransactionModel) {
      id = await db.insert(tableName, item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (item is Map<String, dynamic>) {
      id = await db.insert(tableName, item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return id;
  }

  @override
  Future<void> update(item) async {
    if (item is TransactionModel) {
      await db.update(tableName, item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
    } else if (item is Map<String, dynamic>) {
      await db
          .update(tableName, item, where: 'id = ?', whereArgs: [item["id"]]);
    }
  }

  @override
  Future<void> insertOrUpdate(TransactionModel transactionModel) async {
    final TransactionModel? transactionModelExists =
        await findByServerID(transactionModel.serverID);
    //DateTime now = DateTime.now();
    if (transactionModelExists != null) {
      // data exist, need update db
      await update(transactionModel);
    } else {
      // data not exist, insert data
      await insert(transactionModel);
    }
  }

  @override
  Future<TransactionModel?> find(
    Uint8List externalTransactionID,
    String serverWalletID,
    String serverAccountID,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where:
            'externalTransactionID = ? and serverWalletID = ? and serverAccountID = ?',
        whereArgs: [externalTransactionID, serverWalletID, serverAccountID]);
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<TransactionModel?> findByServerID(String serverID) async {
    final List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'serverID = ?', whereArgs: [serverID]);
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<TransactionModel>> findAllByServerAccountID(
    String serverAccountID,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'serverAccountID = ?', whereArgs: [serverAccountID]);
    if (maps.isNotEmpty) {
      return maps
          .map(TransactionModel.fromMap)
          .toList()
          .cast<TransactionModel>();
    }
    return [];
  }

  @override
  Future<void> deleteByServerID(String id) {
    // TODO(fix): implement deleteByServerID
    throw UnimplementedError();
  }
}
