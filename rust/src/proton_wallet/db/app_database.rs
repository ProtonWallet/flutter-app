use log::info;
use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{
    dao::{
        account_dao::AccountDaoImpl, address_dao::AddressDao,
        bitcoin_address_dao::BitcoinAddressDao, contacts_dao::ContactsDao,
        exchange_rate_dao::ExchangeRateDao, proton_user_dao::ProtonUserDao,
        proton_user_key_dao::ProtonUserKeyDaoImpl, transaction_dao::TransactionDao,
        wallet_dao::WalletDaoImpl, wallet_user_settings_dao::WalletUserSettingsDao,
    },
    database::{
        database::BaseDatabase, migration::SimpleMigration, migration_container::MigrationContainer,
    },
    Result,
};
use crate::proton_wallet::db::database::migration::Migration;

#[derive(Debug)]
pub struct AppDatabase {
    pub version: u32,
    pub reset_version: u32,
    pub db_reset: bool,
    pub migration_container: MigrationContainer,
    pub account_dao: AccountDaoImpl,
    pub wallet_dao: WalletDaoImpl,
    pub address_dao: AddressDao,
    pub bitcoin_address_dao: BitcoinAddressDao,
    pub contacts_dao: ContactsDao,
    pub exchange_rate_dao: ExchangeRateDao,
    pub proton_user_dao: ProtonUserDao,
    pub proton_user_key_dao: ProtonUserKeyDaoImpl,
    pub transaction_dao: TransactionDao,
    pub wallet_user_settings_dao: WalletUserSettingsDao,
}

impl Default for AppDatabase {
    fn default() -> Self {
        Self::new("./test_proton_wallet_rust_db.sqlite")
    }
}

impl AppDatabase {
    pub fn new(database_url: &str) -> Self {
        let conn = Arc::new(Mutex::new(Connection::open(database_url).unwrap()));
        AppDatabase {
            version: 3,
            reset_version: 1,
            db_reset: false,
            migration_container: MigrationContainer::new(),
            account_dao: AccountDaoImpl::new(conn.clone()),
            wallet_dao: WalletDaoImpl::new(conn.clone()),
            address_dao: AddressDao::new(conn.clone()),
            bitcoin_address_dao: BitcoinAddressDao::new(conn.clone()),
            contacts_dao: ContactsDao::new(conn.clone()),
            exchange_rate_dao: ExchangeRateDao::new(conn.clone()),
            proton_user_dao: ProtonUserDao::new(conn.clone()),
            proton_user_key_dao: ProtonUserKeyDaoImpl::new(conn.clone()),
            transaction_dao: TransactionDao::new(conn.clone()),
            wallet_user_settings_dao: WalletUserSettingsDao::new(conn.clone()),
        }
    }

    pub async fn reset(&self) -> Result<()> {
        self.drop_all_tables().await?;
        self.build_database(1).await
    }

    pub async fn drop_all_tables(&self) -> Result<()> {
        let _ = self.account_dao.database.drop_table().await;
        Ok(())
    }

    pub fn build_migration(&mut self) {
        let migrations = vec![
            SimpleMigration::new(1, 2, {
                let wallet_database = self.wallet_dao.database.clone();
                let account_database = self.account_dao.database.clone();
                let address_database = self.address_dao.database.clone();
                let bitcoin_address_database = self.bitcoin_address_dao.database.clone();
                let contacts_database = self.contacts_dao.database.clone();
                let exchange_rate_database = self.exchange_rate_dao.database.clone();
                let proton_user_database = self.proton_user_dao.database.clone();
                let proton_user_key_database = self.proton_user_key_dao.database.clone();
                let transaction_database = self.transaction_dao.database.clone();
                let wallet_user_settings_database = self.wallet_user_settings_dao.database.clone();
                move || {
                    let wallet_database = wallet_database.clone();
                    let account_database = account_database.clone();
                    let address_database = address_database.clone();
                    let bitcoin_address_database = bitcoin_address_database.clone();
                    let contacts_database = contacts_database.clone();
                    let exchange_rate_database = exchange_rate_database.clone();
                    let proton_user_database = proton_user_database.clone();
                    let proton_user_key_database = proton_user_key_database.clone();
                    let transaction_database = transaction_database.clone();
                    let wallet_user_settings_database = wallet_user_settings_database.clone();
                    async move {
                        let _ = wallet_database.migration_0().await;
                        let _ = account_database.migration_0().await;
                        let _ = address_database.migration_0().await;
                        let _ = bitcoin_address_database.migration_0().await;
                        let _ = contacts_database.migration_0().await;
                        let _ = exchange_rate_database.migration_0().await;
                        let _ = proton_user_database.migration_0().await;
                        let _ = proton_user_key_database.migration_0().await;
                        let _ = transaction_database.migration_0().await;
                        let _ = wallet_user_settings_database.migration_0().await;
                    }
                }
            }),
            SimpleMigration::new(2, 3, {
                let account_database = self.account_dao.database.clone();
                move || {
                    let account_database = account_database.clone();
                    async move {
                        let _ = account_database.migration_1().await;
                    }
                }
            }),
        ];
        self.migration_container.add_migrations(migrations);
    }

    pub async fn init(&mut self) -> Result<()> {
        self.build_migration();
        Ok(())
    }

    pub async fn build_database(&self, old_version: u32) -> Result<()> {
        let upgrade_migrations = self
            .migration_container
            .find_migration_path(old_version, self.version);

        info!(
            "Migration appDatabase from Ver.{} to Ver.{}",
            old_version, self.version
        );

        if let Some(migrations) = upgrade_migrations {
            for migration in migrations {
                migration.migrate().await;
            }
        } else {
            info!("nothing to migrate");
        }

        self.check_and_update_version().await
    }

    pub async fn check_and_update_version(&self) -> Result<()> {
        // TODO:: use rust local storage to save version
        Ok(())
    }

    pub fn needs_resync(&self) -> bool {
        self.db_reset
    }
}
