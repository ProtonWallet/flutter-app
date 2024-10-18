use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, table_names::TableName};
use crate::proton_wallet::db::Result;

#[derive(Debug, Clone)]
pub struct AddressDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for AddressDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        AddressDatabase {
            conn,
            table_name: TableName::Address,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl AddressDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<()> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                server_id TEXT NOT NULL,
                email TEXT NOT NULL,
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
    use crate::proton_wallet::db::database::address::AddressDatabase;
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "address_table";
        let db = AddressDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);

        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("server_id").await.unwrap());
        assert!(db.column_exists("email").await.unwrap());
        assert!(db.column_exists("server_wallet_id").await.unwrap());
        assert!(db.column_exists("server_account_id").await.unwrap());
    }
}
