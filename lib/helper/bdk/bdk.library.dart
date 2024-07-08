import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/api/rust_api.dart';
import 'package:wallet/rust/frb_generated.dart';

class BdkLibrary {
  Future<void> clearLocalCache() async {
    String? path;
    if (Platform.isWindows || Platform.isLinux) {
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      path = join(appDocumentsDir.path, "databases");
    } else {
      path = await getDatabasesPath();
      if (!path.contains("databases")) {
        path = join(path, "databases");
      }
    }

    final dir = Directory(path);
    if (await dir.exists()) {
      List<FileSystemEntity> entities = dir.listSync();
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          String fileName = basename(entity.path);
          bool delete = false;
          if (!delete && fileName.endsWith(".sqlite")) {
            delete = true;
          }
          if (!delete && fileName.endsWith("true.db")) {
            delete = true;
          }
          if (!delete && fileName.endsWith("false.db")) {
            delete = true;
          }
          if (!delete && fileName.contains("_m_")) {
            delete = true;
          }
          if (delete) {
            logger.i("removing bdk db: ${entity.path}");
            entity.deleteSync();
          }
        }
      }
    }
  }

  @Deprecated("Use the function in Blockchain client instead")
  Future<bool> fullSyncWalletWithWallet(
    String walletID,
    String accountID,
  ) async {
    try {
      // Define the function to be run in the isolate
      Future<void> isolateTask(String walletID, String accountID) async {
        await RustLib.init();
        var account = await WalletManager.loadWalletWithID(walletID, accountID);
        var blockClient = await Api.createEsploraBlockchainWithApi();
        await blockClient.fullSync(
          account: account!,
          stopGap: appConfig.stopGap,
        );
        RustLib.dispose();
      }

      await Isolate.run(() => isolateTask(walletID, accountID));
      return true;
    } on FormatException catch (e, stacktrace) {
      logger.e(
        "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}",
      );
    } catch (e, stacktrace) {
      logger.e(
        "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}",
      );
    }
    return false;
  }

  Future<void> partialSyncWalletWithID(
    FrbBlockchainClient blockchain,
    FrbAccount account,
  ) async {
    try {
      await Isolate.run(() async => {
            await RustLib.init(),
            if (await blockchain.shouldSync(account: account))
              {
                await blockchain.partialSync(account: account),
              },
            RustLib.dispose()
          });
    } on FormatException catch (e, stacktrace) {
      logger.e(
        "Bdk wallet partial sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}",
      );
    }
  }

  Future<bool> fullSyncWallet(
    FrbBlockchainClient blockchain,
    FrbAccount account,
  ) async {
    try {
      await blockchain.fullSync(
        account: account,
        stopGap: appConfig.stopGap,
      );
      return true;
    } on FormatException catch (e, stacktrace) {
      logger.e(
          "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}");
    } catch (e, stacktrace) {
      logger.e(
          "Bdk wallet full sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}");
    }
    return false;
  }

  Future<void> partialSyncWallet(
      FrbBlockchainClient blockchain, FrbAccount account) async {
    try {
      await Isolate.run(() async => {
            await RustLib.init(),
            if (await blockchain.shouldSync(account: account))
              {
                await blockchain.partialSync(account: account),
              },
            RustLib.dispose()
          });
    } on FormatException catch (e, stacktrace) {
      logger.e(
          "Bdk wallet partial sync error: ${e.toString()} stacktrace: ${stacktrace.toString()}");
    }
  }
}
