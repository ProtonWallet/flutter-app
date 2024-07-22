import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
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
    if (dir.existsSync()) {
      final List<FileSystemEntity> entities = dir.listSync();
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          final String fileName = basename(entity.path);
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

  Future<bool> fullSyncWallet(
    FrbBlockchainClient blockchain,
    FrbAccount account,
  ) async {
    try {
      await blockchain.fullSync(
        account: account,
        stopGap: BigInt.from(appConfig.stopGap),
      );
      return true;
    } on FormatException catch (e, stacktrace) {
      logger.e("Bdk wallet full sync error: $e stacktrace: $stacktrace");
    } catch (e, stacktrace) {
      logger.e("Bdk wallet full sync error: $e stacktrace: $stacktrace");
    }
    return false;
  }

  Future<void> partialSyncWallet(
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
      logger.e("Bdk wallet partial sync error: $e stacktrace: $stacktrace");
    }
  }
}
