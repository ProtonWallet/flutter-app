import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/contacts.model.dart';
import 'package:wallet/models/database/base.dao.dart';
import 'package:wallet/models/database/contacts.database.dart';

abstract class ContactsDao extends ContactsDatabase implements BaseDao {
  ContactsDao(super.db, super.tableName);

  Future<void> insertOrUpdate(String serverContactID, String name, String email,
      String canonicalEmail, int isProton);
  Future<ContactsModel?> findByServerContactID(String serverContactID);
  Future<List<ContactsModel>> findAll();
}

class ContactsDaoImpl extends ContactsDao {
  ContactsDaoImpl(Database db) : super(db, 'contacts');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteByServerID(String id) async {
    await db.delete(tableName, where: 'serverContactID = ?', whereArgs: [id]);
  }

  @override
  Future<List<ContactsModel>> findAll() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => ContactsModel.fromMap(maps[index]));
  }

  @override
  Future<int> insert(item) async {
    int id = 0;
    if (item is ContactsModel) {
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
    if (item is ContactsModel) {
      await db.update(tableName, item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
    } else if (item is Map<String, dynamic>) {
      await db
          .update(tableName, item, where: 'id = ?', whereArgs: [item["id"]]);
    }
  }

  @override
  Future<void> insertOrUpdate(String serverContactID, String name, String email,
      String canonicalEmail, int isProton) async {
    final ContactsModel? contactsModel =
        await findByServerContactID(serverContactID);
    if (contactsModel != null) {
      await update({
        "id": contactsModel.id,
        "name": name,
        "email": email,
        "canonicalEmail": canonicalEmail,
        "isProton": isProton,
      });
    } else {
      await insert({
        "serverContactID": serverContactID,
        "name": name,
        "email": email,
        "canonicalEmail": canonicalEmail,
        "isProton": isProton,
      });
    }
  }

  @override
  Future findById(int id) {
    throw UnimplementedError(); // no need for this function
  }

  @override
  Future<ContactsModel?> findByServerContactID(String serverContactID) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'serverContactID = ?', whereArgs: [serverContactID]);
    if (maps.isNotEmpty) {
      return ContactsModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future findByServerID(String serverID) {
    throw UnimplementedError();
  }
}
