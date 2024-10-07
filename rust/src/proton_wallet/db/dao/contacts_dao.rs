use crate::proton_wallet::db::database::error::DatabaseError;
use crate::proton_wallet::db::database::{contacts::ContactsDatabase, database::BaseDatabase};
use crate::proton_wallet::db::model::contacts_model::ContactsModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct ContactsDao {
    conn: Arc<Mutex<Connection>>,
    pub database: ContactsDatabase,
}

impl ContactsDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = ContactsDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl ContactsDao {
    pub async fn upsert(
        &self,
        item: &ContactsModel,
    ) -> Result<Option<ContactsModel>, DatabaseError> {
        if (self.get_by_server_id(&item.server_contact_id).await?).is_some() {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.server_contact_id).await
    }

    pub async fn insert(&self, item: &ContactsModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO contacts_table (server_contact_id, name, email, canonical_email, is_proton) 
            VALUES (?1, ?2, ?3, ?4, ?5)",
            params![
                item.server_contact_id,
                item.name,
                item.email,
                item.canonical_email,
                item.is_proton
            ]
        );
        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                eprintln!("Something went wrong: {}", e);
                Err(e)
            }
        }
    }

    pub async fn update(&self, item: &ContactsModel) -> Result<Option<ContactsModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE contacts_table SET server_contact_id = ?1, name = ?2, email = ?3, canonical_email = ?4, is_proton = ?5 WHERE id = ?6",
            params![
                item.server_contact_id,
                item.name,
                item.email,
                item.canonical_email,
                item.is_proton,
                item.id.unwrap_or_default()
            ]
        )?;

        if rows_affected == 0 {
            return Err(rusqlite::Error::StatementChangedRows(0));
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        self.get(item.id.unwrap_or_default()).await
    }

    pub async fn get(&self, id: u32) -> Result<Option<ContactsModel>> {
        self.database.get_by_id(id).await
    }

    pub async fn get_by_server_id(
        &self,
        server_id: &str,
    ) -> Result<Option<ContactsModel>, DatabaseError> {
        self.database
            .get_by_column_id("server_contact_id", server_id)
            .await
    }

    pub async fn get_all(&self) -> Result<Vec<ContactsModel>> {
        self.database.get_all().await
    }

    pub async fn delete_by_server_id(&self, server_id: &str) -> Result<(), DatabaseError> {
        self.database
            .delete_by_column_id("server_contact_id", server_id)
            .await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::contacts_dao::ContactsDao;
    use crate::proton_wallet::db::model::contacts_model::ContactsModel;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_contacts_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS contacts_table (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    server_contact_id TEXT NOT NULL,
                    name TEXT NOT NULL,
                    email TEXT NOT NULL,
                    canonical_email TEXT NOT NULL,
                    is_proton INTEGER NOT NULL
                )
                "#,
                [],
            );
        }
        let contacts_dao = ContactsDao::new(conn_arc);
        let contacts = contacts_dao.get_all().await.unwrap();
        assert_eq!(contacts.len(), 0);

        let mut contact = ContactsModel {
            id: Some(1),
            server_contact_id: "server_contact_123".to_string(),
            name: "John Doe".to_string(),
            email: "john.doe@example.com".to_string(),
            canonical_email: "johndoe@example.com".to_string(),
            is_proton: 1,
        };

        // test insert
        let upsert_result = contacts_dao.upsert(&contact).await.unwrap().unwrap();
        assert_eq!(upsert_result.id.unwrap(), 1);

        // test query
        let query_item = contacts_dao
            .get(upsert_result.id.unwrap())
            .await
            .unwrap()
            .unwrap();
        assert_eq!(query_item.server_contact_id, "server_contact_123");
        assert_eq!(query_item.name, "John Doe");
        assert_eq!(query_item.email, "john.doe@example.com");
        assert_eq!(query_item.canonical_email, "johndoe@example.com");
        assert_eq!(query_item.is_proton, 1);

        let query_item = contacts_dao
            .get_by_server_id(&contact.server_contact_id)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(query_item.server_contact_id, "server_contact_123");
        assert_eq!(query_item.name, "John Doe");
        assert_eq!(query_item.email, "john.doe@example.com");
        assert_eq!(query_item.canonical_email, "johndoe@example.com");
        assert_eq!(query_item.is_proton, 1);

        contact.is_proton = 0;
        contact.name = "Hello world".to_string();
        let upsert_result = contacts_dao.upsert(&contact).await.unwrap().unwrap();
        assert_eq!(upsert_result.id.unwrap(), 1);
        assert_eq!(upsert_result.server_contact_id, "server_contact_123");
        assert_eq!(upsert_result.name, "Hello world");
        assert_eq!(upsert_result.email, "john.doe@example.com");
        assert_eq!(upsert_result.canonical_email, "johndoe@example.com");
        assert_eq!(upsert_result.is_proton, 0);

        let contacts = contacts_dao.get_all().await.unwrap();
        assert_eq!(contacts.len(), 1);

        let _ = contacts_dao.delete_by_server_id("server12345").await;

        let contacts = contacts_dao.get_all().await.unwrap();
        assert_eq!(contacts.len(), 1);

        let _ = contacts_dao.delete_by_server_id("server_contact_123").await;

        let contacts = contacts_dao.get_all().await.unwrap();
        assert_eq!(contacts.len(), 0);
    }
}
