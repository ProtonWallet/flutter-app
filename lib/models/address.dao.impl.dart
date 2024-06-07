import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/address.model.dart';
import 'package:wallet/models/database/address.database.dart';
import 'package:wallet/models/database/base.dao.dart';

abstract class AddressDao extends AddressDatabase implements BaseDao {
  AddressDao(super.db, super.tableName);

  Future<List<AddressModel>> findByServerAccountID(String serverAccountID);
  Future<AddressModel?> findByServerID(String serverID);

  Future<void> deleteByServerID(String serverID);
  Future<void> deleteByServerAccountID(String serverAccountID);
}

class AddressDaoImpl extends AddressDao {
  AddressDaoImpl(Database db) : super(db, 'address');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => AddressModel.fromMap(maps[index]));
  }

  @override
  Future<int> insert(item) async {
    int id = 0;
    if (item is AddressModel) {
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
    if (item is AddressModel) {
      await db.update(tableName, item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
    } else if (item is Map<String, dynamic>) {
      await db
          .update(tableName, item, where: 'id = ?', whereArgs: [item["id"]]);
    }
  }

  @override
  Future findById(int id) {
    throw UnimplementedError(); // no need for this function
  }

  @override
  Future<List<AddressModel>> findByServerAccountID(
      String serverAccountID) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'serverAccountID = ?', whereArgs: [serverAccountID]);
    if (maps.isNotEmpty) {
      return maps.map((e) => AddressModel.fromMap(e)).toList();
    }
    return [];
  }

  @override
  Future<void> deleteByServerID(String serverID) async {
    await db.delete(tableName, where: 'serverID = ?', whereArgs: [serverID]);
  }

  @override
  Future<AddressModel?> findByServerID(String serverID) async {
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'serverID = ?', whereArgs: [serverID]);
    if (maps.isNotEmpty) {
      return AddressModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> deleteByServerAccountID(String serverAccountID) async{
    await db.delete(tableName, where: 'serverAccountID = ?', whereArgs: [serverAccountID]);
  }
}
