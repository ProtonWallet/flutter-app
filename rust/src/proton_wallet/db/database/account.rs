use log::error;
use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, error::DatabaseError, table_names::TableName};

#[derive(Debug, Clone)]
pub struct AccountDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for AccountDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        AccountDatabase {
            conn,
            table_name: TableName::Accounts,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl AccountDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<(), DatabaseError> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                account_id TEXT,
                wallet_id TEXT,
                derivation_path TEXT,
                label TEXT,
                script_type INTEGER,
                create_time INTEGER,
                modify_time INTEGER,
                fiat_currency TEXT,
                priority INTEGER,
                last_used_index INTEGER,
                UNIQUE (wallet_id, derivation_path)
            )
            "#,
                self.table_name().as_str()
            )
            .as_str(),
        )
        .await?;
        self.add_index("wallet_id").await?;
        self.add_index("account_id").await?;
        Ok(())
    }

    pub async fn migration_1(&self) -> Result<(), DatabaseError> {
        if let Err(e) = self.drop_column("pool_size").await {
            error!("Failed to drop column pool_size: {:?}", e);
        }
        self.add_column("pool_size", "INTEGER DEFAULT 10").await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::database::account::AccountDatabase;
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "account_table";
        let db = AccountDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(&table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("account_id").await.unwrap());
        assert!(db.column_exists("wallet_id").await.unwrap());
        assert!(db.column_exists("derivation_path").await.unwrap());
        assert!(db.column_exists("label").await.unwrap());
        assert!(db.column_exists("script_type").await.unwrap());
        assert!(db.column_exists("create_time").await.unwrap());
        assert!(db.column_exists(&"modify_time").await.unwrap());
        assert!(db.column_exists("fiat_currency").await.unwrap());
        assert!(db.column_exists("priority").await.unwrap());
        assert!(db.column_exists("last_used_index").await.unwrap());
        assert!(!db.column_exists("pool_size").await.unwrap());
        let result = db.migration_1().await;
        assert!(result.is_ok());
        assert!(db.column_exists("pool_size").await.unwrap());
    }
}
