use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, table_names::TableName, Result};

#[derive(Debug, Clone)]
pub struct WalletDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for WalletDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        WalletDatabase {
            conn,
            table_name: TableName::Wallet,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl WalletDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<()> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                passphrase INTEGER NOT NULL,
                public_key TEXT NOT NULL,
                imported INTEGER NOT NULL,
                priority INTEGER NOT NULL,
                status INTEGER NOT NULL,
                type INTEGER NOT NULL,
                create_time INTEGER NOT NULL,
                modify_time INTEGER NOT NULL,
                user_id TEXT NOT NULL,
                wallet_id TEXT NOT NULL,
                account_count INTEGER NOT NULL,
                balance REAL NOT NULL,
                fingerprint TEXT,
                show_wallet_recovery INTEGER NOT NULL,
                migration_required INTEGER NOT NULL,
                legacy INTEGER,
                UNIQUE (wallet_id)
            )
            "#,
                self.table_name().as_str()
            )
            .as_str(),
        )
        .await?;
        self.add_index("wallet_id").await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use crate::proton_wallet::db::database::wallet::WalletDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "wallet_table";
        let db = WalletDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);
        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("name").await.unwrap());
        assert!(db.column_exists("passphrase").await.unwrap());
        assert!(db.column_exists("public_key").await.unwrap());
        assert!(db.column_exists("imported").await.unwrap());
        assert!(db.column_exists("priority").await.unwrap());
        assert!(db.column_exists("status").await.unwrap());
        assert!(db.column_exists("type").await.unwrap());
        assert!(db.column_exists("create_time").await.unwrap());
        assert!(db.column_exists("modify_time").await.unwrap());
        assert!(db.column_exists("user_id").await.unwrap());
        assert!(db.column_exists("wallet_id").await.unwrap());
        assert!(db.column_exists("account_count").await.unwrap());
        assert!(db.column_exists("balance").await.unwrap());
        assert!(db.column_exists("fingerprint").await.unwrap());
        assert!(db.column_exists("show_wallet_recovery").await.unwrap());
        assert!(db.column_exists("migration_required").await.unwrap());
        assert!(db.column_exists("legacy").await.unwrap());
    }
}
