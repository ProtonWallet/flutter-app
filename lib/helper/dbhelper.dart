import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/address.dao.impl.dart';
import 'package:wallet/models/bitcoin.address.dao.impl.dart';
import 'package:wallet/models/contacts.dao.impl.dart';
import 'package:wallet/models/database/app.database.dart';
import 'package:wallet/models/exchangerate.dao.impl.dart';
import 'package:wallet/models/transaction.dao.impl.dart';
import 'package:wallet/models/transaction.info.dao.impl.dart';
import 'package:wallet/models/wallet.dao.impl.dart';

class DBHelper {
  static AppDatabase? _appDatabase;

  static Future<Database> get database async {
    if (_appDatabase != null) {
      return _appDatabase!.db;
    }
    init();
    return _appDatabase!.db;
  }

  static AccountDao? get accountDao {
    if (_appDatabase != null) {
      return _appDatabase!.accountDao;
    }
    return null;
  }

  static AddressDao? get addressDao {
    if (_appDatabase != null) {
      return _appDatabase!.addressDao;
    }
    return null;
  }

  static WalletDao? get walletDao {
    if (_appDatabase != null) {
      return _appDatabase!.walletDao;
    }
    return null;
  }

  static TransactionDao? get transactionDao {
    if (_appDatabase != null) {
      return _appDatabase!.transactionDao;
    }
    return null;
  }

  static ExchangeRateDao? get exchangeRateDao {
    if (_appDatabase != null) {
      return _appDatabase!.exchangeRateDao;
    }
    return null;
  }

  static ContactsDao? get contactsDao {
    if (_appDatabase != null) {
      return _appDatabase!.contactsDao;
    }
    return null;
  }

  static TransactionInfoDao? get transactionInfoDao {
    if (_appDatabase != null) {
      return _appDatabase!.transactionInfoDao;
    }
    return null;
  }

  static BitcoinAddressDao? get bitcoinAddressDao {
    if (_appDatabase != null) {
      return _appDatabase!.bitcoinAddressDao;
    }
    return null;
  }

  static Future<void> init() async {
    /// This method will init the appDatabase, then build tables to latest version if needed
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final int appDatabaseVersion =
        preferences.getInt(PreferenceKeys.appDatabaseVersion) ?? 1;

    _appDatabase = AppDatabase();
    await _appDatabase!.init(await AppDatabase.getDatabase());
    await _appDatabase!.buildDatabase(oldVersion: appDatabaseVersion);

    preferences.setInt(
        PreferenceKeys.appDatabaseVersion, _appDatabase!.version);
  }

  static Future<void> reset() async {
    /// This method will clean all data in appDatabase, then rebuild tables
    if (_appDatabase != null) {
      await _appDatabase!.reset();

      await _appDatabase!.buildDatabase();

      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setInt(
          PreferenceKeys.appDatabaseVersion, _appDatabase!.version);
    }
  }
}
