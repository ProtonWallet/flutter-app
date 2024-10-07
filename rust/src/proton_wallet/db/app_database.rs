use crate::proton_wallet::db::database::migration::Migration;
use rusqlite::Connection;
use rusqlite::Result;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::dao::{
    account_dao::AccountDao, address_dao::AddressDao, bitcoin_address_dao::BitcoinAddressDao,
    contacts_dao::ContactsDao, exchange_rate_dao::ExchangeRateDao, proton_user_dao::ProtonUserDao,
    proton_user_key_dao::ProtonUserKeyDao, transaction_dao::TransactionDao, wallet_dao::WalletDao,
    wallet_user_settings_dao::WalletUserSettingsDao,
};
use super::database::database::BaseDatabase;

use super::database::migration::SimpleMigration;
use super::database::migration_container::MigrationContainer;

#[derive(Debug)]
pub struct AppDatabase {
    pub version: u32,
    pub reset_version: u32,
    pub db_reset: bool,
    pub migration_container: MigrationContainer,
    pub account_dao: AccountDao,
    pub wallet_dao: WalletDao,
    pub address_dao: AddressDao,
    pub bitcoin_address_dao: BitcoinAddressDao,
    pub contacts_dao: ContactsDao,
    pub exchange_rate_dao: ExchangeRateDao,
    pub proton_user_dao: ProtonUserDao,
    pub proton_user_key_dao: ProtonUserKeyDao,
    pub transaction_dao: TransactionDao,
    pub wallet_user_settings_dao: WalletUserSettingsDao,
}

impl AppDatabase {
    pub fn new(database_url: &str) -> Self {
        let conn = Arc::new(Mutex::new(Connection::open(database_url).unwrap()));
        AppDatabase {
            version: 3,
            reset_version: 1,
            db_reset: false,
            migration_container: MigrationContainer::new(),
            account_dao: AccountDao::new(conn.clone()),
            wallet_dao: WalletDao::new(conn.clone()),
            address_dao: AddressDao::new(conn.clone()),
            bitcoin_address_dao: BitcoinAddressDao::new(conn.clone()),
            contacts_dao: ContactsDao::new(conn.clone()),
            exchange_rate_dao: ExchangeRateDao::new(conn.clone()),
            proton_user_dao: ProtonUserDao::new(conn.clone()),
            proton_user_key_dao: ProtonUserKeyDao::new(conn.clone()),
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
                let address_dao = self.address_dao.database.clone();
                let bitcoin_address_dao = self.bitcoin_address_dao.database.clone();
                let contacts_dao = self.contacts_dao.database.clone();
                let exchange_rate_dao = self.exchange_rate_dao.database.clone();
                let proton_user_dao = self.proton_user_dao.database.clone();
                let proton_user_key_dao = self.proton_user_key_dao.database.clone();
                let transaction_dao = self.transaction_dao.database.clone();
                let wallet_user_settings_dao = self.wallet_user_settings_dao.database.clone();
                move || {
                    let _ = wallet_database.migration_0();
                    let _ = account_database.migration_0();
                    let _ = address_dao.migration_0();
                    let _ = bitcoin_address_dao.migration_0();
                    let _ = contacts_dao.migration_0();
                    let _ = exchange_rate_dao.migration_0();
                    let _ = proton_user_dao.migration_0();
                    let _ = proton_user_key_dao.migration_0();
                    let _ = transaction_dao.migration_0();
                    let _ = wallet_user_settings_dao.migration_0();
                }
            }),
            SimpleMigration::new(2, 3, {
                let account_database = self.account_dao.database.clone();
                move || {
                    let _ = account_database.migration_1();
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

        println!(
            "Migration appDatabase from Ver.{} to Ver.{}",
            old_version, self.version
        );

        if let Some(migrations) = upgrade_migrations {
            for migration in migrations {
                migration.migrate();
            }
        } else {
            println!("nothing to migrate");
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
