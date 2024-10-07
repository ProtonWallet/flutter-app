use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, error::DatabaseError, table_names::TableName};

#[derive(Debug, Clone)]
pub struct BitcoinAddressDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for BitcoinAddressDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        BitcoinAddressDatabase {
            conn,
            table_name: TableName::BitcoinAddress,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl BitcoinAddressDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<(), DatabaseError> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                server_id TEXT NOT NULL,
                wallet_id INTEGER NOT NULL,
                account_id INTEGER NOT NULL,
                bitcoin_address TEXT NOT NULL,
                bitcoin_address_index INTEGER NOT NULL,
                in_email_integration_pool INTEGER NOT NULL,
                used INTEGER NOT NULL,
                server_wallet_id TEXT NOT NULL,
                server_account_id TEXT NOT NULL
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
    use crate::proton_wallet::db::database::bitcoin_address::BitcoinAddressDatabase;
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "bitcoin_address_table";
        let db = BitcoinAddressDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("server_id").await.unwrap());
        assert!(db.column_exists("wallet_id").await.unwrap());
        assert!(db.column_exists("account_id").await.unwrap());
        assert!(db.column_exists("bitcoin_address").await.unwrap());
        assert!(db.column_exists("bitcoin_address_index").await.unwrap());
        assert!(db.column_exists("in_email_integration_pool").await.unwrap());
        assert!(db.column_exists("used").await.unwrap());
        assert!(db.column_exists("server_wallet_id").await.unwrap());
        assert!(db.column_exists("server_account_id").await.unwrap());
    }
}
