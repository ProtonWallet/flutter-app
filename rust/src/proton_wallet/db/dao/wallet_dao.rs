use async_trait::async_trait;
use tracing::error;
use rusqlite::{params, Connection};
use std::sync::Arc;
use tokio::sync::Mutex;

use super::Result;
use crate::proton_wallet::db::{
    database::{database::BaseDatabase, wallet::WalletDatabase},
    error::DatabaseError,
    model::{model::ModelBase, wallet_model::WalletModel},
};

#[derive(Debug, Clone)]
pub struct WalletDaoImpl {
    conn: Arc<Mutex<Connection>>,
    pub database: WalletDatabase,
}

impl WalletDaoImpl {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = WalletDatabase::new(conn.clone());
        Self { conn, database }
    }
}

#[async_trait]
pub trait WalletDao: Send + Sync {
    async fn get_by_server_id(&self, server_id: &str) -> Result<Option<WalletModel>>;
    async fn get_all_by_user_id(&self, user_id: &str) -> Result<Vec<WalletModel>>;
    async fn delete_by_wallet_id(&self, wallet_id: &str) -> Result<()>;
    async fn upsert(&self, item: &WalletModel) -> Result<Option<WalletModel>>;
}

#[async_trait]
impl WalletDao for WalletDaoImpl {
    async fn get_by_server_id(&self, server_id: &str) -> Result<Option<WalletModel>> {
        self.database.get_by_column_id("wallet_id", server_id).await
    }

    async fn get_all_by_user_id(&self, user_id: &str) -> Result<Vec<WalletModel>> {
        let conn = self.conn.lock().await;
        let mut stmt =
            conn.prepare("SELECT * FROM wallet_table WHERE user_id = ?1 ORDER BY priority asc")?;
        let account_iter = stmt.query_map([user_id], WalletModel::from_row)?;
        let accounts: Vec<WalletModel> = account_iter.collect::<rusqlite::Result<_>>()?;
        Ok(accounts)
    }
    async fn delete_by_wallet_id(&self, wallet_id: &str) -> Result<()> {
        self.database
            .delete_by_column_id("wallet_id", wallet_id)
            .await
    }

    async fn upsert(&self, item: &WalletModel) -> Result<Option<WalletModel>> {
        if (self.get_by_server_id(&item.wallet_id).await?).is_some() {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.wallet_id).await
    }
}

impl WalletDaoImpl {
    pub async fn insert(&self, wallet: &WalletModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO wallet_table (name, passphrase, public_key, imported, priority, status, type, create_time, modify_time, user_id, wallet_id, account_count, balance, fingerprint, show_wallet_recovery, migration_required, legacy) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16, ?17)",
            params![
                wallet.name,
                wallet.passphrase,
                wallet.public_key,
                wallet.imported,
                wallet.priority,
                wallet.status,
                wallet.type_,
                wallet.create_time,
                wallet.modify_time,
                wallet.user_id,
                wallet.wallet_id,
                wallet.account_count,
                wallet.balance,
                wallet.fingerprint,
                wallet.show_wallet_recovery,
                wallet.migration_required,
                wallet.legacy,
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

    pub async fn get(&self, id: u32) -> Result<Option<WalletModel>> {
        self.database.get_by_id(id).await
    }

    pub async fn get_default_wallet_by_user_id(
        &self,
        user_id: &str,
    ) -> Result<Option<WalletModel>> {
        let conn = self.conn.lock().await;
        let mut stmt = conn.prepare(
            "SELECT * FROM wallet_table WHERE user_id = ?1 ORDER BY priority asc LIMIT 1",
        )?;
        let result = stmt.query_row(params![user_id], WalletModel::from_row);
        Ok(result.ok())
    }

    pub async fn get_all(&self) -> Result<Vec<WalletModel>> {
        self.database.get_all().await
    }

    pub async fn update(&self, wallet: &WalletModel) -> Result<Option<WalletModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE wallet_table SET 
                name = ?1, 
                passphrase = ?2, 
                public_key = ?3, 
                imported = ?4, 
                priority = ?5, 
                status = ?6, 
                type = ?7, 
                create_time = ?8, 
                modify_time = ?9, 
                user_id = ?10, 
                wallet_id = ?11, 
                account_count = ?12, 
                balance = ?13, 
                fingerprint = ?14, 
                show_wallet_recovery = ?15, 
                migration_required = ?16, 
                legacy = ?17 
                WHERE id = ?18",
            params![
                wallet.name,
                wallet.passphrase,
                wallet.public_key,
                wallet.imported,
                wallet.priority,
                wallet.status,
                wallet.type_,
                wallet.create_time,
                wallet.modify_time,
                wallet.user_id,
                wallet.wallet_id,
                wallet.account_count,
                wallet.balance,
                wallet.fingerprint,
                wallet.show_wallet_recovery,
                wallet.migration_required,
                wallet.legacy,
                wallet.id
            ],
        )?;

        if rows_affected == 0 {
            return Err(DatabaseError::NoChangedRows);
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        self.get(wallet.id).await
    }

    pub async fn delete(&self, id: u32) -> Result<()> {
        self.database.delete_by_id(id).await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::wallet_dao::{WalletDao, WalletDaoImpl};
    use crate::proton_wallet::db::model::wallet_model::WalletModel;
    use rusqlite::Connection;
    use std::sync::Arc;
    use tokio::sync::Mutex;

    #[tokio::test]
    async fn test_wallet_dao() {
        let conn_arc = Arc::new(Mutex::new(Connection::open_in_memory().unwrap()));
        {
            // create table
            let conn_arc_cp = Arc::clone(&conn_arc);
            let conn = conn_arc_cp.lock().await;
            let _ = conn.execute(
                r#"
                CREATE TABLE IF NOT EXISTS wallet_table (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    passphrase INTEGER NOT NULL,
                    public_key TEXT NOT NULL,
                    imported INTEGER NOT NULL,
                    priority INTEGER NOT NULL,
                    status INTEGER NOT NULL,
                    type INTEGER NOT NULL,
                    create_time INTEGER NOT NULL,
                    modify_time INTEGER NOT NULL,
                    user_id TEXT NOT NULL,
                    wallet_id TEXT NOT NULL,
                    account_count INTEGER NOT NULL,
                    balance REAL NOT NULL,
                    fingerprint TEXT,
                    show_wallet_recovery INTEGER NOT NULL,
                    migration_required INTEGER NOT NULL,
                    legacy INTEGER,
                    UNIQUE (wallet_id)
                )
                "#,
                [],
            );
        }
        let wallet_dao = WalletDaoImpl::new(conn_arc);
        let wallets = wallet_dao.get_all().await.unwrap();
        assert_eq!(wallets.len(), 0);
        let wallet = WalletModel {
            id: 1,
            name: "MyWallet".to_string(),
            passphrase: 0,
            public_key: "binary_encoded_string".to_string(),
            imported: 0,
            priority: 5,
            status: 1,
            type_: 2,
            create_time: 1633072800,
            modify_time: 1633159200,
            user_id: "user123".to_string(),
            wallet_id: "wallet123".to_string(),
            account_count: 3,
            balance: 150.75,
            fingerprint: Some("abc123xyz".to_string()),
            show_wallet_recovery: 1,
            migration_required: 0,
            legacy: Some(1),
        };

        // test insert
        let mut result = wallet_dao.upsert(&wallet).await.unwrap().unwrap();
        assert_eq!(result.id, 1);

        let wallets = wallet_dao.get_all_by_user_id("user123").await.unwrap();
        assert_eq!(wallets.len(), 1);
        let wallets = wallet_dao.get_all_by_user_id("user456").await.unwrap();
        assert_eq!(wallets.len(), 0);

        // test query
        let query_wallet = wallet_dao.get(result.id).await.unwrap().unwrap();
        assert_eq!(query_wallet.name, "MyWallet");
        assert_eq!(query_wallet.passphrase, 0);
        assert_eq!(query_wallet.account_count, 3);
        assert_eq!(query_wallet.balance, 150.75);
        assert_eq!(query_wallet.legacy, Some(1));

        let query_wallet = wallet_dao
            .get_default_wallet_by_user_id("user123")
            .await
            .unwrap()
            .unwrap();
        assert_eq!(query_wallet.name, "MyWallet");
        assert_eq!(query_wallet.passphrase, 0);
        assert_eq!(query_wallet.account_count, 3);
        assert_eq!(query_wallet.balance, 150.75);
        assert_eq!(query_wallet.legacy, Some(1));

        let wallets = wallet_dao.get_all().await.unwrap();
        assert_eq!(wallets.len(), 1);

        // test update
        result.balance = 199.0;
        result.account_count = 4;
        result.legacy = Some(0);
        result.name = "Hello world".to_string();
        let result_update = wallet_dao.upsert(&result).await.unwrap().unwrap();
        assert_eq!(result_update.name, "Hello world");
        assert_eq!(result_update.passphrase, 0);
        assert_eq!(result_update.account_count, 4);
        assert_eq!(result_update.balance, 199.0);
        assert_eq!(result_update.legacy, Some(0));

        // test delete
        let _ = wallet_dao.delete_by_wallet_id("wallet_id").await;
        let wallets = wallet_dao.get_all_by_user_id("user123").await.unwrap();
        assert_eq!(wallets.len(), 1);
        let _ = wallet_dao.delete_by_wallet_id("wallet123").await;
        let wallets = wallet_dao.get_all_by_user_id("user123").await.unwrap();
        assert_eq!(wallets.len(), 0);
    }
}
