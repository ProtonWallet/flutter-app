import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/base.dao.dart';
import 'wallet.model.dart';

abstract class WalletDao extends BaseDao {
  WalletDao(super.db, super.tableName);

  Future<int> counts();
}

class WalletDaoImpl extends WalletDao {
  WalletDaoImpl(Database db) : super(db, 'wallet');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
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
  Future<void> initTable() async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userID INTEGER,
          name TEXT,
          mnemonic BLOB,
          passphrase INTEGER,
          publicKey BLOB,
          imported INTEGER,
          priority INTEGER,
          status INTEGER,
          type INTEGER,
          createTime INTEGER,
          modifyTime INTEGER,
          localDBName TEXT
        )
    ''');
  }

  @override
  Future<int> counts() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.length;
  }
}
