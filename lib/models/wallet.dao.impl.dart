import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/base.dao.dart';
import 'wallet.model.dart';

abstract class WalletDao extends BaseDao {
  WalletDao(super.db, super.tableName);

  Future<int> counts();
  Future<WalletModel?> getWalletByServerWalletID(String serverWalletID);

  Future<WalletModel?> getFirstPriorityWallet();
}

class WalletDaoImpl extends WalletDao {
  WalletDaoImpl(Database db) : super(db, 'wallet');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: 'priority desc');
    return List.generate(
        maps.length, (index) => WalletModel.fromMap(maps[index]));
  }

  @override
  Future findById(int id) async {
    List<Map<String, dynamic>> maps =
    await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    } else {
      return null;
    }
  }


  @override
  Future<WalletModel?> getWalletByServerWalletID(String serverWalletID) async {
    List<Map<String, dynamic>> maps =
    await db.query(tableName, where: 'serverWalletID = ?', whereArgs: [serverWalletID]);
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  @override
  Future<WalletModel?> getFirstPriorityWallet() async {
    List<Map<String, dynamic>> maps =
    await db.query(tableName, where: 'status = ?', whereArgs: [WalletModel.statusActive], orderBy: 'priority asc', limit: 1);
    if (maps.isNotEmpty) {
      return WalletModel.fromMap(maps.first);
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
  Future<int> counts() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.length;
  }
}
