import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.dao.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/database/bitcoin.address.database.dart';

abstract class BitcoinAddressDao extends BitcoinAddressDatabase
    implements BaseDao {
  BitcoinAddressDao(super.db, super.tableName);

  Future<void> insertOrUpdate(
      {required String serverWalletID,
      required String serverAccountID,
      required String bitcoinAddress,
      required int bitcoinAddressIndex,
      required int inEmailIntegrationPool,
      required int used});

  Future<BitcoinAddressModel?> findBitcoinAddressInAccount(
    String bitcoinAddress,
    String serverAccountID,
  );

  Future<BitcoinAddressModel?> findLatestUnusedLocalBitcoinAddress(
    String serverWalletID,
    String serverAccountID,
  );

  Future<int> getUnusedPoolCount(
    String serverWalletID,
    String serverAccountID,
  );

  Future<bool> isMine(
      String serverWalletID, String serverAccountID, String bitcoinAddress);

  Future<List<BitcoinAddressModel>> findByWallet(String serverWalletID,
      {String orderBy = "desc"});

  Future<List<BitcoinAddressModel>> findByWalletAccount(
      String serverWalletID, String serverAccountID,
      {String orderBy = "desc"});

  Future<List> findAll();
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
      {required String serverWalletID,
      required String serverAccountID,
      required String bitcoinAddress,
      required int bitcoinAddressIndex,
      required int inEmailIntegrationPool,
      required int used}) async {
    BitcoinAddressModel? bitcoinAddressModel =
        await findBitcoinAddressInAccount(bitcoinAddress, serverAccountID);
    if (bitcoinAddressModel != null) {
      await update({
        "id": bitcoinAddressModel.id,
        "walletID": 0, // deprecated
        "accountID": 0, // deprecated
        "bitcoinAddress": bitcoinAddress,
        "bitcoinAddressIndex": bitcoinAddressIndex,
        "inEmailIntegrationPool": inEmailIntegrationPool,
        "used": used,
      });
    } else {
      await insert({
        "walletID": 0, // deprecated
        "accountID": 0, // deprecated
        "serverWalletID": serverWalletID,
        "serverAccountID": serverAccountID,
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
  Future<BitcoinAddressModel?> findBitcoinAddressInAccount(
    String bitcoinAddress,
    String serverAccountID,
  ) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'bitcoinAddress = ? and serverAccountID = ?',
        whereArgs: [bitcoinAddress, serverAccountID]);
    if (maps.isNotEmpty) {
      return BitcoinAddressModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<BitcoinAddressModel?> findLatestUnusedLocalBitcoinAddress(
    String serverWalletID,
    String serverAccountID,
  ) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where:
            'serverWalletID = ? and serverAccountID = ? and inEmailIntegrationPool = ?',
        whereArgs: [serverWalletID, serverAccountID, 0],
        orderBy: 'bitcoinAddressIndex desc');
    if (maps.isNotEmpty) {
      return BitcoinAddressModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> getUnusedPoolCount(
    String serverWalletID,
    String serverAccountID,
  ) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where:
            'serverWalletID = ? and serverAccountID = ? and inEmailIntegrationPool = ?',
        whereArgs: [serverWalletID, serverAccountID, 1],
        orderBy: 'bitcoinAddressIndex desc');
    if (maps.isNotEmpty) {
      return maps.length;
    }
    return 0;
  }

  @override
  Future<bool> isMine(String serverWalletID, String serverAccountID,
      String bitcoinAddress) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where:
            'serverWalletID = ? and serverAccountID = ? and bitcoinAddress = ?',
        whereArgs: [serverWalletID, serverAccountID, bitcoinAddress],
        orderBy: 'bitcoinAddressIndex desc');
    return maps.isNotEmpty;
  }

  @override
  Future<List<BitcoinAddressModel>> findByWallet(String serverWalletID,
      {String orderBy = "desc"}) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'serverWalletID = ?',
        whereArgs: [serverWalletID],
        orderBy: 'bitcoinAddressIndex $orderBy');
    return List.generate(
        maps.length, (index) => BitcoinAddressModel.fromMap(maps[index]));
  }

  @override
  Future<List<BitcoinAddressModel>> findByWalletAccount(
      String serverWalletID, String serverAccountID,
      {String orderBy = "desc"}) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: 'serverWalletID = ? and serverAccountID = ?',
        whereArgs: [serverWalletID, serverAccountID],
        orderBy: 'bitcoinAddressIndex $orderBy');
    return List.generate(
        maps.length, (index) => BitcoinAddressModel.fromMap(maps[index]));
  }

  @override
  Future<void> deleteByServerID(String id) {
    // TODO: implement deleteByServerID
    throw UnimplementedError();
  }

  @override
  Future findByServerID(String serverID) {
    // TODO: implement findByServerID
    throw UnimplementedError();
  }
}
