use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, error::DatabaseError, table_names::TableName};

#[derive(Debug, Clone)]
pub struct ProtonUserDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for ProtonUserDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        ProtonUserDatabase {
            conn,
            table_name: TableName::ProtonUser,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl ProtonUserDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<(), DatabaseError> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
                user_id TEXT NOT NULL, 
                name TEXT NOT NULL, 
                used_space INTEGER NOT NULL, 
                currency TEXT NOT NULL, 
                credit INTEGER NOT NULL, 
                create_time INTEGER NOT NULL, 
                max_space INTEGER NOT NULL, 
                max_upload INTEGER NOT NULL, 
                role INTEGER NOT NULL, 
                private INTEGER NOT NULL, 
                subscribed INTEGER NOT NULL, 
                services INTEGER NOT NULL, 
                delinquent INTEGER NOT NULL, 
                organization_private_key TEXT NULL, 
                email TEXT NULL, 
                display_name TEXT NULL
            )
            "#,
                self.table_name().as_str()
            )
            .as_str(),
        )
        .await?;
        self.add_index("user_id").await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use crate::proton_wallet::db::database::proton_user::ProtonUserDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "users_table";
        let db = ProtonUserDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("user_id").await.unwrap());
        assert!(db.column_exists("name").await.unwrap());
        assert!(db.column_exists("used_space").await.unwrap());
        assert!(db.column_exists("currency").await.unwrap());
        assert!(db.column_exists("credit").await.unwrap());
        assert!(db.column_exists("create_time").await.unwrap());
        assert!(db.column_exists("max_space").await.unwrap());
        assert!(db.column_exists("max_upload").await.unwrap());
        assert!(db.column_exists("role").await.unwrap());
        assert!(db.column_exists("private").await.unwrap());
        assert!(db.column_exists("subscribed").await.unwrap());
        assert!(db.column_exists("services").await.unwrap());
        assert!(db.column_exists("delinquent").await.unwrap());
        assert!(db.column_exists("organization_private_key").await.unwrap());
        assert!(db.column_exists("email").await.unwrap());
        assert!(db.column_exists("display_name").await.unwrap());
    }
}
