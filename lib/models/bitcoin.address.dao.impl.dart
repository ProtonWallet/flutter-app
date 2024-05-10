import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/base.dao.dart';
import 'package:wallet/models/bitcoin.address.model.dart';

abstract class BitcoinAddressDao extends BaseDao {
  BitcoinAddressDao(super.db, super.tableName);

  Future<void> insertOrUpdate(
      {required int walletID,
      required int accountID,
      required String bitcoinAddress,
      required int bitcoinAddressIndex,
      required int inEmailIntegrationPool,
      required int used});

  Future<BitcoinAddressModel?> findByBitcoinAddress(String bitcoinAddress);
  Future<BitcoinAddressModel?> findLatestUnusedLocalBitcoinAddress(int walletID, int accountID);
  Future<int> getUnusedPoolCount(int walletID, int accountID);
}

class BitcoinAddressDaoImpl extends BitcoinAddressDao {
  BitcoinAddressDaoImpl(Database db) : super(db, 'bitcoinAddress');

  @override
  Future<void> delete(int id) async {
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List> findAll() async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(
        maps.length, (index) => BitcoinAddressModel.fromMap(maps[index]));
  }

  @override
  Future<int> insert(item) async {
    int id = 0;
    if (item is BitcoinAddressModel) {
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
    if (item is BitcoinAddressModel) {
      await db.update(tableName, item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
    } else if (item is Map<String, dynamic>) {
      await db
          .update(tableName, item, where: 'id = ?', whereArgs: [item["id"]]);
    }
  }

  @override
  Future<void> insertOrUpdate(
      {required int walletID,
      required int accountID,
      required String bitcoinAddress,
      required int bitcoinAddressIndex,
      required int inEmailIntegrationPool,
      required int used}) async {
    BitcoinAddressModel? bitcoinAddressModel =
        await findByBitcoinAddress(bitcoinAddress);
    if (bitcoinAddressModel != null) {
      await update({
        "id": bitcoinAddressModel.id,
        "walletID": walletID,
        "accountID": accountID,
        "bitcoinAddress": bitcoinAddress,
        "bitcoinAddressIndex": bitcoinAddressIndex,
        "inEmailIntegrationPool": inEmailIntegrationPool,
        "used": used,
      });
    } else {
      await insert({
        "walletID": walletID,
        "accountID": accountID,
        "bitcoinAddress": bitcoinAddress,
        "bitcoinAddressIndex": bitcoinAddressIndex,
        "inEmailIntegrationPool": inEmailIntegrationPool,
        "used": used,
      });
    }
  }

  @override
  Future findById(int id) {
    throw UnimplementedError(); // no need for this function
  }

  @override
  Future<BitcoinAddressModel?> findByBitcoinAddress(
      String bitcoinAddress) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'bitcoinAddress = ?', whereArgs: [bitcoinAddress]);
    if (maps.isNotEmpty) {
      return BitcoinAddressModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<BitcoinAddressModel?> findLatestUnusedLocalBitcoinAddress(int walletID, int accountID) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'walletID = ? and accountID = ? and inEmailIntegrationPool = ?', whereArgs: [walletID, accountID, 0], orderBy: 'bitcoinAddressIndex desc');
    if (maps.isNotEmpty) {
      return BitcoinAddressModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> getUnusedPoolCount(int walletID, int accountID) async{
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'walletID = ? and accountID = ? and inEmailIntegrationPool = ?', whereArgs: [walletID, accountID, 1], orderBy: 'bitcoinAddressIndex desc');
    if (maps.isNotEmpty) {
      return maps.length;
    }
    return 0;
  }
}
