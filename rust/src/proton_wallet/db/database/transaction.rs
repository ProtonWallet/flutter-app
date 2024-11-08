use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, table_names::TableName, Result};

#[derive(Debug, Clone)]
pub struct TransactionDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for TransactionDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        TransactionDatabase {
            conn,
            table_name: TableName::Transactions,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl TransactionDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<()> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                type INTEGER NOT NULL,
                label TEXT NOT NULL,
                external_transaction_id TEXT NOT NULL,
                create_time INTEGER NOT NULL,
                modify_time INTEGER NOT NULL,
                hashed_transaction_id TEXT NOT NULL,
                transaction_id TEXT NOT NULL,
                transaction_time TEXT NOT NULL,
                exchange_rate_id TEXT NOT NULL,
                server_wallet_id TEXT NOT NULL,
                server_account_id TEXT NOT NULL,
                server_id TEXT NOT NULL,
                sender TEXT,
                tolist TEXT,
                subject TEXT,
                body TEXT
            )
            "#,
                self.table_name().as_str()
            )
            .as_str(),
        )
        .await?;
        self.add_index("server_id").await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use crate::proton_wallet::db::database::transaction::TransactionDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "transaction_table";
        let db = TransactionDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("type").await.unwrap());
        assert!(db.column_exists("label").await.unwrap());
        assert!(db.column_exists("external_transaction_id").await.unwrap());
        assert!(db.column_exists("create_time").await.unwrap());
        assert!(db.column_exists("modify_time").await.unwrap());
        assert!(db.column_exists("hashed_transaction_id").await.unwrap());
        assert!(db.column_exists("transaction_id").await.unwrap());
        assert!(db.column_exists("transaction_time").await.unwrap());
        assert!(db.column_exists("exchange_rate_id").await.unwrap());
        assert!(db.column_exists("server_wallet_id").await.unwrap());
        assert!(db.column_exists("server_account_id").await.unwrap());
        assert!(db.column_exists("server_id").await.unwrap());
        assert!(db.column_exists("sender").await.unwrap());
        assert!(db.column_exists("tolist").await.unwrap());
        assert!(db.column_exists("subject").await.unwrap());
        assert!(db.column_exists("body").await.unwrap());
    }
}
