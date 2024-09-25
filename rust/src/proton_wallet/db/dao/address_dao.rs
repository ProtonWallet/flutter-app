use crate::proton_wallet::db::database::error::DatabaseError;
use crate::proton_wallet::db::database::{address::AddressDatabase, database::BaseDatabase};
use crate::proton_wallet::db::model::address_model::AddressModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct AddressDao {
    conn: Arc<Mutex<Connection>>,
    pub database: AddressDatabase,
}

impl AddressDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = AddressDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl AddressDao {
    pub async fn upsert(&self, item: &AddressModel) -> Result<Option<AddressModel>, DatabaseError> {
        if let Some(_) = self.get_by_server_id(&item.server_id).await? {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.server_id).await
    }

    pub async fn insert(&self, item: &AddressModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO address_table (server_id, email, server_wallet_id, server_account_id) 
            VALUES (?1, ?2, ?3, ?4)",
            params![
                item.server_id,
                item.email,
                item.server_wallet_id,
                item.server_account_id
            ],
        );
        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                eprintln!("Something went wrong: {}", e);
                Err(e)
            }
        }
    }

    pub async fn update(&self, item: &AddressModel) -> Result<Option<AddressModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE address_table SET server_id = ?1, email = ?2, server_wallet_id = ?3, server_account_id = ?4 WHERE id = ?5",
            params![
                item.server_id,
                item.email,
                item.server_wallet_id,
                item.server_account_id,
                item.id
            ]
        )?;

        if rows_affected == 0 {
            return Err(rusqlite::Error::StatementChangedRows(0));
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        Ok(self.get(item.id).await?)
    }

    /// Get a record by id
    pub async fn get(&self, id: u32) -> Result<Option<AddressModel>> {
        self.database.get_by_id(id).await
    }

    pub async fn get_all_by_account_id(
        &self,
        account_id: &str,
    ) -> Result<Vec<AddressModel>, DatabaseError> {
        self.database
            .get_all_by_column_id("server_account_id", account_id)
            .await
    }

    pub async fn get_by_server_id(
        &self,
        server_id: &str,
    ) -> Result<Option<AddressModel>, DatabaseError> {
        self.database.get_by_column_id("server_id", server_id).await
    }

    pub async fn get_all(&self) -> Result<Vec<AddressModel>> {
        self.database.get_all().await
    }

    pub async fn delete_by_server_id(&self, server_id: &str) -> Result<(), DatabaseError> {
        self.database
            .delete_by_column_id("server_id", server_id)
            .await
    }

    pub async fn delete_by_account_id(&self, server_account_id: &str) -> Result<(), DatabaseError> {
        self.database
            .delete_by_column_id("server_account_id", server_account_id)
            .await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::address_dao::AddressDao;
    use crate::proton_wallet::db::model::address_model::AddressModel;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_address_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS address_table (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    server_id TEXT NOT NULL,
                    email TEXT NOT NULL,
                    server_wallet_id TEXT NOT NULL,
                    server_account_id TEXT NOT NULL
                )
                "#,
                [],
            );
        }
        let address_dao = AddressDao::new(conn_arc);
        let addresses = address_dao.get_all().await.unwrap();
        assert_eq!(addresses.len(), 0);

        let address = AddressModel {
            id: 1,
            server_id: "server123".to_string(),
            email: "user@example.com".to_string(),
            server_wallet_id: "wallet123".to_string(),
            server_account_id: "account123".to_string(),
        };

        let mut address2 = address.clone();
        address2.server_id = "server999".to_string();
        address2.email = "test@proton.me".to_string();

        let mut address3 = address.clone();
        address3.server_id = "server666".to_string();
        address3.email = "test3@proton.me".to_string();
        address3.server_account_id = "account2".to_string();

        // test insert
        let upsert_result = address_dao.upsert(&address).await.unwrap().unwrap();
        assert_eq!(upsert_result.id, 1);
        let upsert_result = address_dao.upsert(&address2).await.unwrap().unwrap();
        assert_eq!(upsert_result.id, 2);
        let upsert_result = address_dao.upsert(&address3).await.unwrap().unwrap();
        assert_eq!(upsert_result.id, 3);

        // test query
        let query_address = address_dao.get(1).await.unwrap().unwrap();
        assert_eq!(query_address.server_id, "server123");
        assert_eq!(query_address.email, "user@example.com");
        assert_eq!(query_address.server_wallet_id, "wallet123");
        assert_eq!(query_address.server_account_id, "account123");

        let addresses = address_dao.get_all().await.unwrap();
        assert_eq!(addresses.len(), 3);

        let addresses = address_dao
            .get_all_by_account_id("account123")
            .await
            .unwrap();
        assert_eq!(addresses.len(), 2);
        let addresses = address_dao
            .get_all_by_account_id("account12345")
            .await
            .unwrap();
        assert_eq!(addresses.len(), 0);
        let addresses = address_dao.get_all_by_account_id("account2").await.unwrap();
        assert_eq!(addresses.len(), 1);

        // test update
        let mut query_address = address_dao.get(3).await.unwrap().unwrap();
        assert_eq!(query_address.server_id, "server666");
        assert_eq!(query_address.email, "test3@proton.me");
        assert_eq!(query_address.server_wallet_id, "wallet123");
        assert_eq!(query_address.server_account_id, "account2");
        query_address.email = "new.email@proton.me".to_string();
        let _ = address_dao.upsert(&query_address).await.unwrap().unwrap();

        let query_address = address_dao.get(3).await.unwrap().unwrap();
        assert_eq!(query_address.server_id, "server666");
        assert_eq!(query_address.email, "new.email@proton.me");
        assert_eq!(query_address.server_wallet_id, "wallet123");
        assert_eq!(query_address.server_account_id, "account2");

        // test delete
        let _ = address_dao.delete_by_server_id("server666666").await;

        let addresses = address_dao.get_all().await.unwrap();
        assert_eq!(addresses.len(), 3);

        let _ = address_dao.delete_by_server_id("server666").await;
        let addresses = address_dao.get_all().await.unwrap();
        assert_eq!(addresses.len(), 2);

        let _ = address_dao.delete_by_account_id("account123").await;
        let addresses = address_dao.get_all().await.unwrap();
        assert_eq!(addresses.len(), 0);
    }
}
