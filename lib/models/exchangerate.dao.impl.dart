import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.dao.dart';
import 'package:wallet/models/database/exchangerate.database.dart';
import 'package:wallet/models/exchangerate.model.dart';

abstract class ExchangeRateDao extends ExchangeRateDatabase implements BaseDao {
  ExchangeRateDao(super.db, super.tableName);

  Future<ExchangeRateModel?> findByServerID(String serverID);
}

class ExchangeRateDaoImpl extends ExchangeRateDao {
  ExchangeRateDaoImpl(Database db) : super(db, 'exchangeRate');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => ExchangeRateModel.fromMap(maps[index]));
  }

  @override
  Future<int> insert(item) async {
    int id = 0;
    if (item is ExchangeRateModel) {
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
    throw UnimplementedError(); // no need for this function
  }

  @override
  Future findById(int id) {
    throw UnimplementedError(); // no need for this function
  }

  @override
  Future<ExchangeRateModel?> findByServerID(String serverID) async {
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'serverID = ?', whereArgs: [serverID]);
    if (maps.isNotEmpty) {
      return ExchangeRateModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> deleteByServerID(String id) {
    // TODO: implement deleteByServerID
    throw UnimplementedError();
  }
}
