// place holder

use rusqlite::{Connection, Result};
use std::sync::{Arc, Mutex};
// use super::migration_container::MigrationContainer;

pub struct AppDatabase {
    version: i32,
    reset_version: i32,
    db_reset: bool,
    db: Option<Arc<Mutex<Connection>>>,
    // migration_container: MigrationContainer,
    // account_dao: Option<AccountDaoImpl>,
    // wallet_dao: Option<WalletDaoImpl>,
    // transaction_dao: Option<TransactionDaoImpl>,
    // contacts_dao: Option<ContactsDaoImpl>,
    // address_dao: Option<AddressDaoImpl>,
    // bitcoin_address_dao: Option<BitcoinAddressDaoImpl>,
    // transaction_info_dao: Option<TransactionInfoDaoImpl>,
    // exchange_rate_dao: Option<ExchangeRateDaoImpl>,
}

impl Default for AppDatabase {
    fn default() -> Self {
        Self::new()
    }
}

impl AppDatabase {
    pub fn new() -> Self {
        AppDatabase {
            version: 24,
            reset_version: 1,
            db_reset: false,
            db: None,
            // migration_container: MigrationContainer::new(),
            // account_dao: None,
            // wallet_dao: None,
            // transaction_dao: None,
            // contacts_dao: None,
            // address_dao: None,
            // bitcoin_address_dao: None,
            // transaction_info_dao: None,
            // exchange_rate_dao: None,
        }
    }

    pub async fn reset(&self) -> Result<()> {
        self.drop_all_tables().await?;
        self.build_database(false, 1).await
    }

    pub async fn drop_all_tables(&self) -> Result<()> {
        // self.wallet_dao.as_ref().unwrap().drop_table().await?;
        // self.account_dao.as_ref().unwrap().drop_table().await?;
        // self.transaction_dao.as_ref().unwrap().drop_table().await?;
        // self.contacts_dao.as_ref().unwrap().drop_table().await?;
        // self.address_dao.as_ref().unwrap().drop_table().await?;
        // self.bitcoin_address_dao
        //     .as_ref()
        //     .unwrap()
        //     .drop_table()
        //     .await?;
        // self.transaction_info_dao
        //     .as_ref()
        //     .unwrap()
        //     .drop_table()
        //     .await?;
        // self.exchange_rate_dao.as_ref().unwrap().drop_table().await
        Ok(())
    }

    pub fn init_dao(&mut self, conn: Arc<Mutex<Connection>>) {
        // self.wallet_dao = Some(WalletDaoImpl::new(conn.clone()));
        // self.account_dao = Some(AccountDaoImpl::new(conn.clone()));
        // self.transaction_dao = Some(TransactionDaoImpl::new(conn.clone()));
        // self.contacts_dao = Some(ContactsDaoImpl::new(conn.clone()));
        // self.address_dao = Some(AddressDaoImpl::new(conn.clone()));
        // self.bitcoin_address_dao = Some(BitcoinAddressDaoImpl::new(conn.clone()));
        // self.transaction_info_dao = Some(TransactionInfoDaoImpl::new(conn.clone()));
        // self.exchange_rate_dao = Some(ExchangeRateDaoImpl::new(conn.clone()));
    }

    pub fn build_migration(&mut self) {
        // let migrations = vec![
        //     Migration::new(1, 2, Box::new(|| Box::pin(async {}))),
        //     Migration::new(
        //         2,
        //         3,
        //         Box::new(move || {
        //             Box::pin(async {
        //                 self.transaction_dao
        //                     .as_ref()
        //                     .unwrap()
        //                     .migration_0()
        //                     .await
        //                     .unwrap();
        //             })
        //         }),
        //     ),
        //     // ... (other migrations follow the same pattern)
        // ];
        // self.migration_container.add_migrations(migrations);
    }

    // pub async fn init(&mut self, conn: Arc<Mutex<Connection>>) -> Result<()> {
    //     self.init_database(conn.clone()).await?;
    //     self.build_migration();
    //     self.init_dao(conn);
    //     Ok(())
    // }

    // pub async fn get_database(db_folder: &str, db_name: &str) -> Result<Arc<Mutex<Connection>>> {
    //     let db_path = match std::env::consts::OS {
    //         "windows" | "linux" => {
    //             let app_documents_dir = dirs::data_dir().unwrap().join(db_folder);
    //             fs::create_dir_all(&app_documents_dir)?;
    //             app_documents_dir.join(db_name)
    //         }
    //         _ => {
    //             let path = dirs::data_dir().unwrap();
    //             fs::create_dir_all(&path)?;
    //             path.join(db_folder).join(db_name)
    //         }
    //     };

    //     let conn = Connection::open(&db_path)?;
    //     info!("dbPath: {:?}", db_path);
    //     Ok(Arc::new(Mutex::new(conn)))
    // }

    // pub async fn init_database(&mut self, conn: Arc<Mutex<Connection>>) -> Result<()> {
    //     let db_guard = conn.lock().unwrap();
    //     if db_guard.is_autocommit() {
    //         info!("db is open, return");
    //         return Ok(());
    //     }
    //     info!("set initialized Database");
    //     self.db = Some(conn);
    //     Ok(())
    // }

    pub async fn build_database(&self, is_testing: bool, old_version: i32) -> Result<()> {
        // let upgrade_migrations = self
        //     .migration_container
        //     .find_migration_path(old_version, self.version);

        // info!(
        //     "Migration appDatabase from Ver.{} to Ver.{}",
        //     old_version, self.version
        // );

        // if let Some(migrations) = upgrade_migrations {
        //     for migration in migrations {
        //         migration.migrate().await?;
        //     }
        // } else {
        //     warn!("nothing to migrate");
        // }

        self.check_and_update_version().await
    }

    pub async fn check_and_update_version(&self) -> Result<()> {
        // let db_guard = self.db.as_ref().unwrap().lock().unwrap();
        // let current_version: i32 =
        //     db_guard.query_row("PRAGMA user_version", NO_PARAMS, |row| row.get(0))?;

        // if current_version < self.version {
        //     info!(
        //         "Current version ({}) is less than required version ({})",
        //         current_version, self.version
        //     );
        // }

        // db_guard.execute(
        //     &format!("PRAGMA user_version = {}", self.version),
        //     NO_PARAMS,
        // )?;

        Ok(())
    }

    pub fn needs_resync(&self) -> bool {
        self.db_reset
    }
}
