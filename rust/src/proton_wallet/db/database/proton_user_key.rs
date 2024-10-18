use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, table_names::TableName};
use crate::proton_wallet::db::Result;

#[derive(Debug, Clone)]
pub struct ProtonUserKeyDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for ProtonUserKeyDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        ProtonUserKeyDatabase {
            conn,
            table_name: TableName::ProtonUserKey,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl ProtonUserKeyDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<()> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                key_id TEXT NOT NULL, 
                user_id TEXT NOT NULL, 
                version INTEGER NOT NULL, 
                private_key TEXT NOT NULL, 
                token TEXT NULL, 
                fingerprint TEXT NULL, 
                recovery_secret TEXT NULL, 
                recovery_secret_signature TEXT NULL, 
                active INTEGER NOT NULL,
                'primary' INTEGER NOT NULL,
                PRIMARY KEY (key_id, user_id))
            "#,
                self.table_name().as_str()
            )
            .as_str(),
        )
        .await?;
        self.add_index("key_id").await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use crate::proton_wallet::db::database::proton_user_key::ProtonUserKeyDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "user_keys_table";
        let db = ProtonUserKeyDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("key_id").await.unwrap());
        assert!(db.column_exists("user_id").await.unwrap());
        assert!(db.column_exists("version").await.unwrap());
        assert!(db.column_exists("private_key").await.unwrap());
        assert!(db.column_exists("token").await.unwrap());
        assert!(db.column_exists("fingerprint").await.unwrap());
        assert!(db.column_exists("recovery_secret").await.unwrap());
        assert!(db.column_exists("recovery_secret_signature").await.unwrap());
        assert!(db.column_exists("active").await.unwrap());
        assert!(db.column_exists("primary").await.unwrap());
    }
}
