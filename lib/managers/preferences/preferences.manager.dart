import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.interface.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';

typedef Logic = Future<void> Function();

class PreferencesManager implements Manager {
  // storage interface
  final PreferencesInterface storage;
  final firstTimeEntryKey = "firstTimeEntry";

  PreferencesManager(this.storage);

  /// function
  Future<void> deleteAll() async {
    await storage.deleteAll();
    await rebuild();
  }

  Future<void> delete(String key) async {
    await storage.delete(key);
  }

  Map toMap() {
    return storage.toMap();
  }

  Future<void> rebuild() async {
    await storage.write(firstTimeEntryKey, false);

    /// we need to mark the `appDatabaseForceVersion` and `appBDKDatabaseForceVersion` to the correct version
    /// since we already call appMigrationManager.init(); in app.viewmodel.dart
    await storage.write(
        PreferenceKeys.appDatabaseForceVersion, driftDatabaseVersion);
    await storage.write(
        PreferenceKeys.appBDKDatabaseForceVersion, bdkDatabaseVersion);
  }

  Future<void> isFirstTimeEntry(Logic run) async {
    await checkif(firstTimeEntryKey, false, run);
  }

  Future<void> checkif(String key, dynamic value, Logic run) async {
    // Get the value
    final dynamic checkValue = await storage.read(key);
    // Check if the value is false
    if (checkValue != value) {
      logger.d('Running logic because checkValue $key is not match');
      await run.call();
      await storage.write(key, value);
    }
  }

  Future<dynamic> read(String key) async {
    return storage.read(key);
  }

  Future<void> write(String key, dynamic value) async {
    await storage.write(key, value);
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {
    await deleteAll();
  }

  @override
  Future<void> login(String userID) async {}

  @override
  Future<void> reload() async {}
}
