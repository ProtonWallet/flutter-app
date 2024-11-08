use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, table_names::TableName, Result};

#[derive(Debug, Clone)]
pub struct ExchangeRateDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for ExchangeRateDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        ExchangeRateDatabase {
            conn,
            table_name: TableName::ExchangeRate,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl ExchangeRateDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<()> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                server_id TEXT NOT NULL,
                bitcoin_unit TEXT NOT NULL,
                fiat_currency TEXT NOT NULL,
                sign TEXT NOT NULL,
                exchange_rate_time TEXT NOT NULL,
                exchange_rate INTEGER NOT NULL,
                cents INTEGER NOT NULL
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
    use crate::proton_wallet::db::database::exchange_rate::ExchangeRateDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "exchange_rate_table";
        let db = ExchangeRateDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);
        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("server_id").await.unwrap());
        assert!(db.column_exists("bitcoin_unit").await.unwrap());
        assert!(db.column_exists("fiat_currency").await.unwrap());
        assert!(db.column_exists("sign").await.unwrap());
        assert!(db.column_exists("exchange_rate_time").await.unwrap());
        assert!(db.column_exists("exchange_rate").await.unwrap());
        assert!(db.column_exists("cents").await.unwrap());
    }
}
