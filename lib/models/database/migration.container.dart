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
    while (startVersion < endVersion) {
      final Map<int, Migration>? targetMap = migrations[startVersion];
      if (targetMap == null) {
        return null;
      }
      final List<int> sortedKeys = targetMap.keys.toList()..sort();
      bool find = false;
      for (int targetVersion in sortedKeys) {
        final bool shouldAddToPath =
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
// TODO(improve): not sure if this is better of not
// List<Migration>? findMigrationPath(int startVersion, int endVersion) {
//   final List<Migration> result = [];
  
//   while (startVersion < endVersion) {
//     final Map<int, Migration>? targetMap = migrations[startVersion];
    
//     if (targetMap == null) {
//       return null; // No migration path from the current startVersion
//     }
    
//     // Get a sorted list of target versions
//     final List<int> sortedKeys = targetMap.keys.toList()..sort();
//     bool migrationFound = false;
    
//     for (int targetVersion in sortedKeys) {
//       // Check if the target version is within the desired range
//       final bool shouldAddToPath = targetVersion <= endVersion && targetVersion > startVersion;
      
//       if (shouldAddToPath) {
//         result.add(targetMap[targetVersion]!);
//         startVersion = targetVersion; // Move to the next version
//         migrationFound = true;
//         break; // Stop searching once a valid migration is found for this version
//       }
//     }
    
//     if (!migrationFound) {
//       return null; // No valid migration found, return null
//     }
//   }
  
//   return result;
// }
