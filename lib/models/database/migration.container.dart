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
    final int start = migration.startVersion;
    final int end = migration.endVersion;
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
    final List<Migration> result = [];
    int start = startVersion;
    while (start < endVersion) {
      final Map<int, Migration>? targetMap = migrations[start];
      if (targetMap == null) {
        return null;
      }
      final List<int> sortedKeys = targetMap.keys.toList()..sort();
      bool find = false;
      for (int targetVersion in sortedKeys) {
        final bool shouldAddToPath =
            targetVersion <= endVersion && targetVersion > start;
        if (shouldAddToPath) {
          result.add(targetMap[targetVersion]!);
          start = targetVersion;
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
