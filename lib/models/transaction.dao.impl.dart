import 'dart:convert';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/base.dao.dart';
import 'package:wallet/models/transaction.model.dart';

abstract class TransactionDao extends BaseDao {
  TransactionDao(super.db, super.tableName);

  Future<void> insertOrUpdate(
      int walletID, Uint8List externalTransactionID, String label);

  Future<TransactionModel?> findByExternalTransactionID(
      Uint8List externalTransactionID);
}

class TransactionDaoImpl extends TransactionDao {
  TransactionDaoImpl(Database db) : super(db, 'walletTransaction');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => TransactionModel.fromMap(maps[index]));
  }

  @override
  Future findById(int id) async {
    List<Map<String, dynamic>> maps =
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
  Future<void> insertOrUpdate(
      int walletID, Uint8List externalTransactionID, String label) async {
    TransactionModel? transactionModel =
        await findByExternalTransactionID(externalTransactionID);
    DateTime now = DateTime.now();
    if (transactionModel != null) {
      // data exist, need update db
      update({
        "id": transactionModel.id,
        "label": utf8.encode(label), // TODO:: encrypt label
        "modifyTime": now.millisecondsSinceEpoch ~/ 1000
      });
    } else {
      // data not exist, insert data
      insert({
        "walletID": walletID,
        "label": utf8.encode(label), // TODO:: encrypt label
        "externalTransactionID": externalTransactionID,
        "createTime": now.millisecondsSinceEpoch ~/ 1000,
        "modifyTime": now.millisecondsSinceEpoch ~/ 1000,
      });
    }
  }

  @override
  Future<TransactionModel?> findByExternalTransactionID(
      Uint8List externalTransactionID) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'externalTransactionID = ?', whereArgs: [externalTransactionID]);
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }
}
