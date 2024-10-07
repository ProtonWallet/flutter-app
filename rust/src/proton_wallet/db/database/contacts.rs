use rusqlite::Connection;
use std::sync::Arc;
use tokio::sync::Mutex;

use super::{database::BaseDatabase, error::DatabaseError, table_names::TableName};

#[derive(Debug, Clone)]
pub struct ContactsDatabase {
    conn: Arc<Mutex<Connection>>,
    table_name: TableName,
}

impl BaseDatabase for ContactsDatabase {
    fn new(conn: Arc<Mutex<Connection>>) -> Self {
        ContactsDatabase {
            conn,
            table_name: TableName::Contacts,
        }
    }

    fn conn(&self) -> &Arc<Mutex<Connection>> {
        &self.conn
    }

    fn table_name(&self) -> &TableName {
        &self.table_name
    }
}

impl ContactsDatabase {
    // You can add specific migration methods here
    pub async fn migration_0(&self) -> Result<(), DatabaseError> {
        self.drop_table().await?;
        self.create_table(
            format!(
                r#"
            CREATE TABLE IF NOT EXISTS `{}` (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                server_contact_id TEXT NOT NULL,
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                canonical_email TEXT NOT NULL,
                is_proton INTEGER NOT NULL
            )
            "#,
                self.table_name().as_str()
            )
            .as_str(),
        )
        .await?;
        self.add_index("server_contact_id").await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::database::contacts::ContactsDatabase;
    use crate::proton_wallet::db::database::database::BaseDatabase;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_database() {
        let conn = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        let table_name = "contacts_table";
        let db = ContactsDatabase::new(conn);
        assert_eq!(db.table_name().as_str(), table_name);
        let result = db.migration_0().await;
        assert!(result.is_ok());
        let exists = db.table_exists(table_name).await.unwrap();
        assert!(exists);

        assert!(db.column_exists("id").await.unwrap());
        assert!(db.column_exists("server_contact_id").await.unwrap());
        assert!(db.column_exists("name").await.unwrap());
        assert!(db.column_exists("email").await.unwrap());
        assert!(db.column_exists("canonical_email").await.unwrap());
        assert!(db.column_exists("is_proton").await.unwrap());
    }
}
