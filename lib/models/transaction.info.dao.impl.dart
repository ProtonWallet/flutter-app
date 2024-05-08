import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/base.dao.dart';
import 'package:wallet/models/transaction.info.model.dart';

abstract class TransactionInfoDao extends BaseDao {
  TransactionInfoDao(super.db, super.tableName);

  Future<void> insertOrUpdate(
      {required Uint8List externalTransactionID,
      required int amountInSATS,
      required int feeInSATS,
      required int isSend,
      required int transactionTime,
      required int feeMode});

  Future<TransactionInfoModel?> findByExternalTransactionID(
      Uint8List externalTransactionID);
}

class TransactionInfoDaoImpl extends TransactionInfoDao {
  TransactionInfoDaoImpl(Database db) : super(db, 'transactionInfo');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => TransactionInfoModel.fromMap(maps[index]));
  }

  @override
  Future<int> insert(item) async {
    int id = 0;
    if (item is TransactionInfoModel) {
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
    if (item is TransactionInfoModel) {
      await db.update(tableName, item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
    } else if (item is Map<String, dynamic>) {
      await db
          .update(tableName, item, where: 'id = ?', whereArgs: [item["id"]]);
    }
  }

  @override
  Future<void> insertOrUpdate(
      {required Uint8List externalTransactionID,
        required int amountInSATS,
        required int feeInSATS,
        required int isSend,
        required int transactionTime,
        required int feeMode}) async {
    TransactionInfoModel? transactionInfoModel =
        await findByExternalTransactionID(externalTransactionID);
    if (transactionInfoModel != null) {
      await update({
        "id": transactionInfoModel.id,
        "externalTransactionID": externalTransactionID,
        "amountInSATS": amountInSATS,
        "feeInSATS": feeInSATS,
        "isSend": isSend,
        "transactionTime": transactionTime,
        "feeMode": feeMode,
      });
    } else {
      await insert({
        "externalTransactionID": externalTransactionID,
        "amountInSATS": amountInSATS,
        "feeInSATS": feeInSATS,
        "isSend": isSend,
        "transactionTime": transactionTime,
        "feeMode": feeMode,
      });
    }
  }

  @override
  Future findById(int id) {
    throw UnimplementedError(); // no need for this function
  }

  @override
  Future<TransactionInfoModel?> findByExternalTransactionID(
      Uint8List externalTransactionID) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'externalTransactionID = ?', whereArgs: [externalTransactionID]);
    if (maps.isNotEmpty) {
      return TransactionInfoModel.fromMap(maps.first);
    }
    return null;
  }
}
