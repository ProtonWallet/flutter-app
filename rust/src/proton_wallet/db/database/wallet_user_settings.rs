use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, table_names::TableName};
use crate::proton_wallet::db::Result;

#[derive(Debug, Clone)]
pub struct WalletUserSettingsDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for WalletUserSettingsDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        WalletUserSettingsDatabase {
            conn,
            table_name: TableName::WalletUserSettings,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl WalletUserSettingsDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<()> {
        self.drop_table().await?;
        self.create_table(
            format!(
            r#"
            CREATE TABLE IF NOT EXISTS `{}` (
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
            self.table_name().as_str()
        ).as_str()
        ).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use crate::proton_wallet::db::database::wallet_user_settings::WalletUserSettingsDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "wallet_user_settings_table";
        let db = WalletUserSettingsDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("user_id").await.unwrap());
        assert!(db.column_exists("bitcoin_unit").await.unwrap());
        assert!(db.column_exists("fiat_currency").await.unwrap());
        assert!(db.column_exists("hide_empty_used_addresses").await.unwrap(),);
        assert!(db.column_exists("show_wallet_recovery").await.unwrap(),);
        assert!(db
            .column_exists("two_factor_amount_threshold")
            .await
            .unwrap());
        assert!(db
            .column_exists("receive_inviter_notification")
            .await
            .unwrap());
        assert!(db
            .column_exists("receive_email_integration_notification")
            .await
            .unwrap());
        assert!(db.column_exists("wallet_created").await.unwrap());
        assert!(db
            .column_exists("accept_terms_and_conditions")
            .await
            .unwrap());
    }
}
