// use std::collections::BTreeMap;
// use std::sync::Arc;

// use log::warn;

// use super::error::DatabaseError;
// use super::migration::Migration;

// pub struct MigrationContainer {
//     migrations: BTreeMap<i32, BTreeMap<i32, Arc<dyn Migration>>>,
// }

// impl MigrationContainer {
//     pub fn new() -> Self {
//         MigrationContainer {
//             migrations: BTreeMap::new(),
//         }
//     }

//     pub fn add_migrations(&mut self, migrations: Vec<Arc<dyn Migration>>) {
//         for migration in migrations {
//             self.add_migration(migration);
//         }
//     }

//     pub fn add_migration(&mut self, migration: Arc<dyn Migration>) {
//         let start = migration.start_version();
//         let end = migration.end_version();

//         let target_map = self.migrations.entry(start).or_insert_with(BTreeMap::new);

//         if target_map.contains_key(&end) {
//             warn!("Override migration from {} to {}", start, end);
//         }
//         target_map.insert(end, migration);
//     }

//     pub fn find_migration_path(
//         &self,
//         start_version: i32,
//         end_version: i32,
//     ) -> Option<Vec<Arc<dyn Migration>>> {
//         let mut result = Vec::new();
//         let mut current_version = start_version;

//         while current_version < end_version {
//             let target_map = self.migrations.get(&current_version)?;

//             let mut sorted_keys: Vec<&i32> = target_map.keys().collect();
//             sorted_keys.sort();

//             let mut found = false;

//             for &target_version in &sorted_keys {
//                 if *target_version <= end_version && *target_version > current_version {
//                     if let Some(migration) = target_map.get(target_version) {
//                         result.push(Arc::clone(migration));
//                         current_version = *target_version;
//                         found = true;
//                         break; // only one migrate at one version
//                     }
//                 }
//             }

//             if !found {
//                 return None;
//             }
//         }

//         Some(result)
//     }

//     pub async fn run_migrations(
//         &self,
//         start_version: i32,
//         end_version: i32,
//     ) -> Result<(), DatabaseError> {
//         if let Some(migrations) = self.find_migration_path(start_version, end_version) {
//             for migration in migrations {
//                 migration.migrate().await?;
//             }
//         } else {
//             return Err(DatabaseError::MigrationError(
//                 "No valid migration path found".into(),
//             ));
//         }
//         Ok(())
//     }
// }
