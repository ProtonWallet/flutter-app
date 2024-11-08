use async_trait::async_trait;
use log::error;
use rusqlite::{params, Connection};
use std::sync::Arc;
use tokio::sync::Mutex;

use super::Result;
use crate::proton_wallet::db::{
    database::{account::AccountDatabase, database::BaseDatabase},
    error::DatabaseError,
    model::account_model::AccountModel,
};

#[derive(Debug, Clone)]
pub struct AccountDaoImpl {
    conn: Arc<Mutex<Connection>>,
    pub database: AccountDatabase,
}

impl AccountDaoImpl {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = AccountDatabase::new(conn.clone());
        Self { conn, database }
    }
}

#[async_trait]
pub trait AccountDao: Send + Sync {
    async fn get_all_by_wallet_id(&self, wallet_id: &str) -> Result<Vec<AccountModel>>;
}

#[async_trait]
impl AccountDao for AccountDaoImpl {
    async fn get_all_by_wallet_id(&self, wallet_id: &str) -> Result<Vec<AccountModel>> {
        self.database
            .get_all_by_column_id("wallet_id", wallet_id)
            .await
    }
}

impl AccountDaoImpl {
    pub async fn upsert(&self, item: &AccountModel) -> Result<Option<AccountModel>> {
        if (self.get_by_server_id(&item.account_id).await?).is_some() {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.account_id).await
    }

    pub async fn insert(&self, item: &AccountModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result = conn.execute(
            "INSERT INTO account_table (account_id, wallet_id, derivation_path, label, script_type, create_time, modify_time, fiat_currency, priority, last_used_index, pool_size) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)",
            params![
                item.account_id,
                item.wallet_id,
                item.derivation_path,
                item.label,
                item.script_type,
                item.create_time,
                item.modify_time,
                item.fiat_currency,
                item.priority,
                item.last_used_index,
                item.pool_size
            ]
        );
        match result {
            Ok(_) => Ok(conn.last_insert_rowid() as u32),
            Err(e) => {
                error!("Something went wrong: {}", e);
                Err(e.into())
            }
        }
    }

    pub async fn update(&self, item: &AccountModel) -> Result<Option<AccountModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE account_table SET account_id = ?1, wallet_id = ?2, derivation_path = ?3, label = ?4, script_type = ?5, create_time = ?6, modify_time = ?7, fiat_currency = ?8, priority = ?9, last_used_index = ?10, pool_size = ?11 WHERE id = ?12",
            params![
                item.account_id,
                item.wallet_id,
                item.derivation_path,
                item.label,
                item.script_type,
                item.create_time,
                item.modify_time,
                item.fiat_currency,
                item.priority,
                item.last_used_index,
                item.pool_size,
                item.id
            ]
        )?;
        if rows_affected == 0 {
            return Err(DatabaseError::NoChangedRows);
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        self.get(item.id).await
    }

    /// Get account by auto increase id
    pub async fn get(&self, id: u32) -> Result<Option<AccountModel>> {
        self.database.get_by_id(id).await
    }

    /// Get all from table
    pub async fn get_all(&self) -> Result<Vec<AccountModel>> {
        self.database.get_all().await
    }

    pub async fn get_by_server_id(&self, server_id: &str) -> Result<Option<AccountModel>> {
        self.database
            .get_by_column_id("account_id", server_id)
            .await
    }

    pub async fn delete(&self, id: u32) -> Result<()> {
        self.database.delete_by_id(id).await
    }

    pub async fn delete_by_account_id(&self, account_id: &str) -> Result<()> {
        self.database
            .delete_by_column_id("account_id", account_id)
            .await
    }

    pub async fn delete_by_wallet_id(&self, account_id: &str) -> Result<()> {
        self.database
            .delete_by_column_id("wallet_id", account_id)
            .await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::account_dao::{AccountDao, AccountDaoImpl};
    use crate::proton_wallet::db::model::account_model::AccountModel;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_account_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
            CREATE TABLE IF NOT EXISTS `account_table` (
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
                pool_size INTEGER DEFAULT 10,
                UNIQUE (wallet_id, derivation_path)
            )
            "#,
                [],
            );
        }
        let account_dao = AccountDaoImpl::new(conn_arc);
        let accounts = account_dao.get_all().await.unwrap();
        assert_eq!(accounts.len(), 0);
        let account_model = AccountModel {
            id: 1,
            account_id: "test_account_id".to_string(),
            wallet_id: "test_wallet_id".to_string(),
            derivation_path: "m/44'/0'/0'/0".to_string(),
            label: "My Account Label".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "USD".to_string(),
            priority: 10,
            last_used_index: 5,
            pool_size: 100,
        };

        let account_model_2 = AccountModel {
            id: 2,
            account_id: "test_account_id_2".to_string(),
            wallet_id: "test_wallet_id_2".to_string(),
            derivation_path: "m/44'/0'/1'/0".to_string(),
            label: "My Account Label 2".to_string(),
            script_type: 0,
            create_time: 1633072800,
            modify_time: 1633159200,
            fiat_currency: "MMR".to_string(),
            priority: 11,
            last_used_index: 0,
            pool_size: 100,
        };

        // test upsert
        let result = account_dao.upsert(&account_model).await.unwrap().unwrap();
        assert_eq!(result.id, 1);
        let result = account_dao.upsert(&account_model_2).await.unwrap().unwrap();
        assert_eq!(result.id, 2);

        // test query
        let accounts = account_dao
            .get_all_by_wallet_id("test_wallet_id_2")
            .await
            .unwrap();
        assert_eq!(accounts.len(), 1);
        let accounts = account_dao
            .get_all_by_wallet_id("test_wallet_id")
            .await
            .unwrap();
        assert_eq!(accounts.len(), 1);
        let accounts = account_dao
            .get_all_by_wallet_id("test_wallet_id_1")
            .await
            .unwrap();
        assert_eq!(accounts.len(), 0);

        let accounts = account_dao.get_all().await.unwrap();
        assert_eq!(accounts.len(), 2);

        assert_eq!(accounts[1].wallet_id, "test_wallet_id_2");
        assert_eq!(accounts[1].account_id, "test_account_id_2");
        assert_eq!(accounts[1].derivation_path, "m/44'/0'/1'/0");
        assert_eq!(accounts[1].script_type, 0);
        assert_eq!(accounts[1].create_time, 1633072800);
        assert_eq!(accounts[1].modify_time, 1633159200);
        assert_eq!(accounts[1].priority, 11);
        assert_eq!(accounts[1].last_used_index, 0);
        assert_eq!(accounts[1].pool_size, 100);
        assert_eq!(accounts[1].fiat_currency, "MMR");

        let mut query_item = account_dao.get(1).await.unwrap().unwrap();
        assert_eq!(query_item.wallet_id, "test_wallet_id");
        assert_eq!(query_item.account_id, "test_account_id");
        assert_eq!(query_item.derivation_path, "m/44'/0'/0'/0");
        assert_eq!(query_item.script_type, 0);
        assert_eq!(query_item.create_time, 1633072800);
        assert_eq!(query_item.modify_time, 1633159200);
        assert_eq!(query_item.priority, 10);
        assert_eq!(query_item.last_used_index, 5);
        assert_eq!(query_item.pool_size, 100);
        assert_eq!(query_item.fiat_currency, "USD");

        // test update
        query_item.fiat_currency = "CHF".to_string();
        query_item.priority = 1;
        query_item.modify_time = 1688888888;
        query_item.last_used_index = 10;

        let updated_item = account_dao.update(&query_item).await.unwrap().unwrap();
        assert_eq!(updated_item.wallet_id, "test_wallet_id");
        assert_eq!(updated_item.account_id, "test_account_id");
        assert_eq!(updated_item.derivation_path, "m/44'/0'/0'/0");
        assert_eq!(updated_item.script_type, 0);
        assert_eq!(updated_item.create_time, 1633072800);
        assert_eq!(updated_item.modify_time, 1688888888);
        assert_eq!(updated_item.priority, 1);
        assert_eq!(updated_item.last_used_index, 10);
        assert_eq!(updated_item.pool_size, 100);
        assert_eq!(query_item.fiat_currency, "CHF");

        // test delete
        let _ = account_dao.delete_by_account_id("test_account_id777").await;
        let accounts = account_dao.get_all().await.unwrap();
        assert_eq!(accounts.len(), 2);

        let _ = account_dao.delete_by_account_id("test_account_id").await;
        let accounts = account_dao.get_all().await.unwrap();
        assert_eq!(accounts.len(), 1);

        assert_eq!(accounts[0].wallet_id, "test_wallet_id_2");
        assert_eq!(accounts[0].account_id, "test_account_id_2");
        assert_eq!(accounts[0].derivation_path, "m/44'/0'/1'/0");
        assert_eq!(accounts[0].script_type, 0);
        assert_eq!(accounts[0].create_time, 1633072800);
        assert_eq!(accounts[0].modify_time, 1633159200);
        assert_eq!(accounts[0].priority, 11);
        assert_eq!(accounts[0].last_used_index, 0);
        assert_eq!(accounts[0].pool_size, 100);
        assert_eq!(accounts[0].fiat_currency, "MMR");

        let query_item = account_dao.get(1).await.unwrap();
        assert!(query_item.is_none());

        let query_item = account_dao.get(2).await.unwrap();
        assert!(query_item.is_some());

        let _ = account_dao.delete_by_wallet_id("test_account_id").await;
        let accounts = account_dao.get_all().await.unwrap();
        assert_eq!(accounts.len(), 1);

        let _ = account_dao.delete_by_wallet_id("test_wallet_id_2").await;
        let accounts = account_dao.get_all().await.unwrap();
        assert_eq!(accounts.len(), 0);
    }
}
