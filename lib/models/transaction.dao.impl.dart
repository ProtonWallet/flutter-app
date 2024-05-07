import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/base.dao.dart';
import 'package:wallet/models/transaction.model.dart';

abstract class TransactionDao extends BaseDao {
  TransactionDao(super.db, super.tableName);

  Future<void> insertOrUpdate(TransactionModel transactionModel);

  Future<List<TransactionModel>> findAllByServerAccountID(String serverAccountID);

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
  Future<void> insertOrUpdate(TransactionModel transactionModel) async {
    TransactionModel? transactionModelExists =
        await findByExternalTransactionID(
            transactionModel.externalTransactionID);
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
  Future<TransactionModel?> findByExternalTransactionID(
      Uint8List externalTransactionID) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'externalTransactionID = ?', whereArgs: [externalTransactionID]);
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<TransactionModel>> findAllByServerAccountID(String serverAccountID) async{
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'serverAccountID = ?', whereArgs: [serverAccountID]);
    if (maps.isNotEmpty) {
      return maps.map((e) => TransactionModel.fromMap(e)).toList().cast<TransactionModel>();
    }
    return [];
  }
}
