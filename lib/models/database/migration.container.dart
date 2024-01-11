import '../../helper/logger.dart';
import 'migration.dart';

class MigrationContainer {
  late Map<int, Map<int, Migration>> migrations;

  MigrationContainer() {
    migrations = {};
  }

  void addMigrations(List<Migration> migrations) {
    for (Migration migration in migrations) {
      addMigration(migration);
    }
  }

  void addMigration(Migration migration) {
    int start = migration.startVersion;
    int end = migration.endVersion;
    Map<int, Migration>? targetMap = migrations[start];
    if (targetMap == null) {
      targetMap = {};
      migrations[start] = targetMap;
    }
    if (targetMap[end] != null) {
      logger.w("Override migration + $migration");
    }
    targetMap[end] = migration;
  }

  List<Migration>? findMigrationPath(int startVersion, int endVersion) {
    List<Migration> result = [];
    while (startVersion < endVersion) {
      Map<int, Migration>? targetMap = migrations[startVersion];
      if (targetMap == null) {
        return null;
      }
      List<int> sortedKeys = targetMap.keys.toList()..sort();
      bool find = false;
      for (int targetVersion in sortedKeys) {
        bool shouldAddToPath =
            targetVersion <= endVersion && targetVersion > startVersion;
        if (shouldAddToPath) {
          result.add(targetMap[targetVersion]!);
          startVersion = targetVersion;
          find = true;
          break; // only one migrate at one version
        }
      }
      if (!find) {
        return null;
      }
    }
    return result;
  }
}
