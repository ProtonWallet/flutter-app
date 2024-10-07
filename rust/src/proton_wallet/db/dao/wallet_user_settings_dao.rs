use crate::proton_wallet::db::database::error::DatabaseError;
use crate::proton_wallet::db::database::{
    database::BaseDatabase, wallet_user_settings::WalletUserSettingsDatabase,
};

use crate::proton_wallet::db::model::wallet_user_settings_model::WalletUserSettingsModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct WalletUserSettingsDao {
    conn: Arc<Mutex<Connection>>,
    pub database: WalletUserSettingsDatabase,
}

impl WalletUserSettingsDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = WalletUserSettingsDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl WalletUserSettingsDao {
    pub async fn upsert(
        &self,
        item: &WalletUserSettingsModel,
    ) -> Result<Option<WalletUserSettingsModel>, DatabaseError> {
        if let Some(_) = self.get_by_user_id(&item.user_id).await? {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_user_id(&item.user_id).await
    }

    pub async fn insert(&self, item: &WalletUserSettingsModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO wallet_user_settings_table (user_id, bitcoin_unit, fiat_currency, hide_empty_used_addresses, show_wallet_recovery, two_factor_amount_threshold, receive_inviter_notification, receive_email_integration_notification, wallet_created, accept_terms_and_conditions) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)",
            params![
                item.user_id,
                item.bitcoin_unit,
                item.fiat_currency,
                item.hide_empty_used_addresses,
                item.show_wallet_recovery,
                item.two_factor_amount_threshold,
                item.receive_inviter_notification,
                item.receive_email_integration_notification,
                item.wallet_created,
                item.accept_terms_and_conditions,
            ]
        );
        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                eprintln!("Something went wrong: {}", e);
                Err(e)
            }
        }
    }

    pub async fn update(
        &self,
        item: &WalletUserSettingsModel,
    ) -> Result<Option<WalletUserSettingsModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE wallet_user_settings_table 
                    SET bitcoin_unit = ?1, 
                        fiat_currency = ?2, 
                        hide_empty_used_addresses = ?3, 
                        show_wallet_recovery = ?4, 
                        two_factor_amount_threshold = ?5, 
                        receive_inviter_notification = ?6, 
                        receive_email_integration_notification = ?7, 
                        wallet_created = ?8, 
                        accept_terms_and_conditions = ?9 
                    WHERE user_id = ?10",
            params![
                item.bitcoin_unit,
                item.fiat_currency,
                item.hide_empty_used_addresses,
                item.show_wallet_recovery,
                item.two_factor_amount_threshold,
                item.receive_inviter_notification,
                item.receive_email_integration_notification,
                item.wallet_created,
                item.accept_terms_and_conditions,
                item.user_id
            ],
        )?;

        if rows_affected == 0 {
            return Err(rusqlite::Error::StatementChangedRows(0));
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        Ok(self.get(&item.user_id).await?)
    }

    pub async fn get(&self, user_id: &str) -> Result<Option<WalletUserSettingsModel>> {
        let result = self.database.get_by_column_id("user_id", user_id).await;
        match result {
            Ok(user_setting) => Ok(user_setting),
            Err(e) => {
                eprintln!("Something went wrong: {}", e);
                Ok(None)
            }
        }
    }

    pub async fn get_by_user_id(
        &self,
        user_id: &str,
    ) -> Result<Option<WalletUserSettingsModel>, DatabaseError> {
        self.database.get_by_column_id("user_id", user_id).await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::{
        dao::wallet_user_settings_dao::WalletUserSettingsDao,
        model::wallet_user_settings_model::WalletUserSettingsModel,
    };
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    #[ignore]
    async fn test_wallet_user_settings_dao_from_local_file() {
        // open existing database from path
        let conn_arc = Arc::new(Mutex::new(
            Connection::open("C:\\Users\\will.hsu\\Documents\\databases\\drift_proton_wallet_db")
                .unwrap(),
        ));

        let wallet_user_settings_dao = WalletUserSettingsDao::new(conn_arc);
        let setting = wallet_user_settings_dao.get_by_user_id("vJxErOgAzrqjwPfvjlhAoDVPoXbDl2URUzd15JcQNwggW6bkwd70KNWozrMpV_d21FITkNqnMAY5WRxwAGclng==").await.unwrap().unwrap();
        assert_eq!(setting.user_id, "vJxErOgAzrqjwPfvjlhAoDVPoXbDl2URUzd15JcQNwggW6bkwd70KNWozrMpV_d21FITkNqnMAY5WRxwAGclng==");
        assert_eq!(setting.bitcoin_unit, "btc");
        assert_eq!(setting.fiat_currency, "chf");
        assert_eq!(setting.hide_empty_used_addresses, 0);
        assert_eq!(setting.show_wallet_recovery, 0);
        assert_eq!(setting.two_factor_amount_threshold, 3.0);
        assert_eq!(setting.receive_inviter_notification, 0);
        assert_eq!(setting.receive_email_integration_notification, 0);
        assert_eq!(setting.wallet_created, 1);
        assert_eq!(setting.accept_terms_and_conditions, 1);
    }

    #[tokio::test]
    async fn test_wallet_user_settings_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS wallet_user_settings_table (
                    user_id TEXT NOT NULL, 
                    bitcoin_unit TEXT NOT NULL, 
                    fiat_currency TEXT NOT NULL, 
                    hide_empty_used_addresses INTEGER NOT NULL CHECK (hide_empty_used_addresses IN (0, 1)), 
                    show_wallet_recovery INTEGER NOT NULL CHECK (show_wallet_recovery IN (0, 1)), 
                    two_factor_amount_threshold REAL NOT NULL, 
                    receive_inviter_notification INTEGER NOT NULL CHECK (receive_inviter_notification IN (0, 1)), 
                    receive_email_integration_notification INTEGER NOT NULL CHECK (receive_email_integration_notification IN (0, 1)), 
                    wallet_created INTEGER NOT NULL CHECK (wallet_created IN (0, 1)), 
                    accept_terms_and_conditions INTEGER NOT NULL CHECK (accept_terms_and_conditions IN (0, 1)), 
                    PRIMARY KEY (user_id)
                )
                "#,
                [],
            );
        }
        let wallet_user_settings_dao = WalletUserSettingsDao::new(conn_arc);
        let setting = wallet_user_settings_dao
            .get_by_user_id("mock_user_id")
            .await
            .unwrap();
        assert!(setting.is_none());

        let mut setting = WalletUserSettingsModel {
            user_id: "mock_user_id".to_string(),
            bitcoin_unit: "MBTC".to_string(),
            fiat_currency: "CNY".to_string(),
            hide_empty_used_addresses: 1,
            show_wallet_recovery: 1,
            two_factor_amount_threshold: 66.66,
            receive_inviter_notification: 0,
            receive_email_integration_notification: 1,
            wallet_created: 0,
            accept_terms_and_conditions: 0,
        };

        // test upsert
        let upsert_item = wallet_user_settings_dao.upsert(&setting).await.unwrap();
        assert_eq!(upsert_item.is_some(), true);

        // test query
        let query_item = wallet_user_settings_dao
            .get_by_user_id("mock_user_id")
            .await
            .unwrap()
            .unwrap();

        assert_eq!(query_item.user_id, "mock_user_id");
        assert_eq!(query_item.bitcoin_unit, "MBTC");
        assert_eq!(query_item.fiat_currency, "CNY");
        assert_eq!(query_item.hide_empty_used_addresses, 1);
        assert_eq!(query_item.show_wallet_recovery, 1);
        assert_eq!(query_item.two_factor_amount_threshold, 66.66);
        assert_eq!(query_item.receive_inviter_notification, 0);
        assert_eq!(query_item.receive_email_integration_notification, 1);
        assert_eq!(query_item.wallet_created, 0);
        assert_eq!(query_item.accept_terms_and_conditions, 0);

        // test update
        setting.bitcoin_unit = "SATS".to_string();
        setting.fiat_currency = "JPY".to_string();
        let upsert_item = wallet_user_settings_dao.upsert(&setting).await.unwrap();
        assert_eq!(upsert_item.is_some(), true);

        let query_item = wallet_user_settings_dao
            .get_by_user_id("mock_user_id")
            .await
            .unwrap()
            .unwrap();

        assert_eq!(query_item.user_id, "mock_user_id");
        assert_eq!(query_item.bitcoin_unit, "SATS");
        assert_eq!(query_item.fiat_currency, "JPY");
        assert_eq!(query_item.hide_empty_used_addresses, 1);
        assert_eq!(query_item.show_wallet_recovery, 1);
        assert_eq!(query_item.two_factor_amount_threshold, 66.66);
        assert_eq!(query_item.receive_inviter_notification, 0);
        assert_eq!(query_item.receive_email_integration_notification, 1);
        assert_eq!(query_item.wallet_created, 0);
        assert_eq!(query_item.accept_terms_and_conditions, 0);
    }
}
