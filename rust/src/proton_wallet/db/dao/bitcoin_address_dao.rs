use crate::proton_wallet::db::database::error::DatabaseError;
use crate::proton_wallet::db::database::{
    bitcoin_address::BitcoinAddressDatabase, database::BaseDatabase,
};
use crate::proton_wallet::db::model::bitcoin_address_model::BitcoinAddressModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug)]
pub struct BitcoinAddressDao {
    conn: Arc<Mutex<Connection>>,
    pub database: BitcoinAddressDatabase,
}

impl BitcoinAddressDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = BitcoinAddressDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl BitcoinAddressDao {
    pub async fn upsert(
        &self,
        item: &BitcoinAddressModel,
    ) -> Result<Option<BitcoinAddressModel>, DatabaseError> {
        if let Some(_) = self.get_by_server_id(&item.server_id).await? {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.server_id).await
    }

    pub async fn insert(&self, item: &BitcoinAddressModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO bitcoin_address_table (server_id, wallet_id, account_id, bitcoin_address, bitcoin_address_index, in_email_integration_pool, used, server_wallet_id, server_account_id) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
            params![
                item.server_id,
                item.wallet_id,
                item.account_id,
                item.bitcoin_address,
                item.bitcoin_address_index,
                item.in_email_integration_pool,
                item.used,
                item.server_wallet_id,
                item.server_account_id
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

    pub async fn update(&self, item: &BitcoinAddressModel) -> Result<Option<BitcoinAddressModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE bitcoin_address_table SET server_id = ?1, wallet_id = ?2, account_id = ?3, bitcoin_address = ?4, bitcoin_address_index = ?5, in_email_integration_pool = ?6, used = ?7, server_wallet_id = ?8, server_account_id = ?9 WHERE id = ?10",
            params![
                item.server_id,
                item.wallet_id,
                item.account_id,
                item.bitcoin_address,
                item.bitcoin_address_index,
                item.in_email_integration_pool,
                item.used,
                item.server_wallet_id,
                item.server_account_id,
                item.id
            ]
        )?;

        if rows_affected == 0 {
            return Err(rusqlite::Error::StatementChangedRows(0));
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        Ok(self.get(item.id.unwrap_or_default()).await?)
    }

    pub async fn get(&self, id: u32) -> Result<Option<BitcoinAddressModel>> {
        self.database.get_by_id(id).await
    }

    pub async fn get_by_server_id(
        &self,
        server_id: &str,
    ) -> Result<Option<BitcoinAddressModel>, DatabaseError> {
        self.database.get_by_column_id("server_id", server_id).await
    }

    pub async fn get_all(&self) -> Result<Vec<BitcoinAddressModel>> {
        self.database.get_all().await
    }

    pub async fn delete_by_account_id(&self, account_id: &str) -> Result<(), DatabaseError> {
        self.database
            .delete_by_column_id("server_account_id", account_id)
            .await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::bitcoin_address_dao::BitcoinAddressDao;
    use crate::proton_wallet::db::model::bitcoin_address_model::BitcoinAddressModel;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_bitcoin_address_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS bitcoin_address_table (
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
                [],
            );
        }
        let bitcoin_address_dao = BitcoinAddressDao::new(conn_arc);
        let bitcoin_addresses = bitcoin_address_dao.get_all().await.unwrap();
        assert_eq!(bitcoin_addresses.len(), 0);

        let bitcoin_address = BitcoinAddressModel {
            id: Some(1),
            server_id: "serverid_1".to_string(),
            wallet_id: 100,
            account_id: 200,
            bitcoin_address: "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa".to_string(),
            bitcoin_address_index: 0,
            in_email_integration_pool: 1,
            used: 0,
            server_wallet_id: "server_wallet_123".to_string(),
            server_account_id: "server_account_456".to_string(),
        };

        let mut bitcoin_address2 = bitcoin_address.clone();
        bitcoin_address2.server_id = "serverid_2".to_string();
        bitcoin_address2.bitcoin_address = "BC3YGWIQK314JOJPDFs2QWIUdd15HIchSHUIU".to_string();
        bitcoin_address2.bitcoin_address_index = 11;
        bitcoin_address2.in_email_integration_pool = 0;
        bitcoin_address2.used = 1;

        // test insert
        let upsert_result = bitcoin_address_dao
            .upsert(&bitcoin_address)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.id.unwrap(), 1);
        let upsert_result = bitcoin_address_dao
            .upsert(&bitcoin_address2)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.id.unwrap(), 2);

        // test query
        let query_item = bitcoin_address_dao.get(1).await.unwrap().unwrap();
        assert_eq!(query_item.server_wallet_id, "server_wallet_123");
        assert_eq!(query_item.server_account_id, "server_account_456");

        let bitcoin_addresses = bitcoin_address_dao.get_all().await.unwrap();
        assert_eq!(bitcoin_addresses.len(), 2);

        // test update
        let mut query_item = bitcoin_address_dao.get(2).await.unwrap().unwrap();
        assert_eq!(query_item.server_wallet_id, "server_wallet_123");
        assert_eq!(query_item.server_account_id, "server_account_456");
        assert_eq!(
            query_item.bitcoin_address,
            "BC3YGWIQK314JOJPDFs2QWIUdd15HIchSHUIU"
        );
        assert_eq!(query_item.bitcoin_address_index, 11);
        assert_eq!(query_item.in_email_integration_pool, 0);
        assert_eq!(query_item.used, 1);

        query_item.bitcoin_address = "BTC111391kDIHjkh89dmNNDkdSDd1dPLPLPu9GUYWG".to_string();
        query_item.bitcoin_address_index = 12;
        query_item.used = 0;

        let upsert_result = bitcoin_address_dao
            .upsert(&query_item)
            .await
            .unwrap()
            .unwrap();
        assert_eq!(upsert_result.id.unwrap(), 2);

        let query_item = bitcoin_address_dao.get(2).await.unwrap().unwrap();
        assert_eq!(query_item.server_wallet_id, "server_wallet_123");
        assert_eq!(query_item.server_account_id, "server_account_456");
        assert_eq!(
            query_item.bitcoin_address,
            "BTC111391kDIHjkh89dmNNDkdSDd1dPLPLPu9GUYWG"
        );
        assert_eq!(query_item.bitcoin_address_index, 12);
        assert_eq!(query_item.in_email_integration_pool, 0);
        assert_eq!(query_item.used, 0);

        // test delete

        let _ = bitcoin_address_dao
            .delete_by_account_id("server_account_4566666")
            .await;

        let bitcoin_addresses = bitcoin_address_dao.get_all().await.unwrap();
        assert_eq!(bitcoin_addresses.len(), 2);

        let _ = bitcoin_address_dao
            .delete_by_account_id("server_account_456")
            .await;
        let bitcoin_addresses = bitcoin_address_dao.get_all().await.unwrap();
        assert_eq!(bitcoin_addresses.len(), 0);
    }
}
