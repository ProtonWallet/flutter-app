use crate::proton_wallet::db::database::error::DatabaseError;
use crate::proton_wallet::db::database::{database::BaseDatabase, wallet::WalletDatabase};
use crate::proton_wallet::db::model::model::ModelBase;
use crate::proton_wallet::db::model::wallet_model::WalletModel;
use rusqlite::{params, Connection, Result};
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Debug, Clone)]
pub struct WalletDao {
    conn: Arc<Mutex<Connection>>,
    pub database: WalletDatabase,
}

impl WalletDao {
    pub fn new(conn: Arc<Mutex<Connection>>) -> Self {
        let database = WalletDatabase::new(conn.clone());
        Self { conn, database }
    }
}

impl WalletDao {
    pub async fn upsert(&self, item: &WalletModel) -> Result<Option<WalletModel>, DatabaseError> {
        if let Some(_) = self.get_by_server_id(&item.wallet_id).await? {
            self.update(item).await?;
        } else {
            self.insert(item).await?;
        }
        self.get_by_server_id(&item.wallet_id).await
    }

    pub async fn insert(&self, wallet: &WalletModel) -> Result<u32> {
        let conn = self.conn.lock().await;
        let result: std::result::Result<usize, rusqlite::Error> = conn.execute(
            "INSERT INTO wallet_table (name, passphrase, public_key, imported, priority, status, type, create_time, modify_time, user_id, wallet_id, account_count, balance, fingerprint, show_wallet_recovery, migration_required) 
            VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15, ?16)",
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
                wallet.migration_required
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

    pub async fn get(&self, id: u32) -> Result<Option<WalletModel>> {
        self.database.get_by_id(id).await
    }

    pub async fn get_by_server_id(
        &self,
        server_id: &str,
    ) -> Result<Option<WalletModel>, DatabaseError> {
        self.database.get_by_column_id("wallet_id", server_id).await
    }

    pub async fn get_default_wallet_by_user_id(
        &self,
        user_id: &str,
    ) -> Result<Option<WalletModel>> {
        let conn = self.conn.lock().await;
        let mut stmt = conn.prepare(
            "SELECT * FROM wallet_table WHERE user_id = ?1 ORDER BY priority asc LIMIT 1",
        )?;
        let result = stmt.query_row(params![user_id], |row| Ok(WalletModel::from_row(row)?));
        Ok(result.ok())
    }

    pub async fn get_all(&self) -> Result<Vec<WalletModel>> {
        self.database.get_all().await
    }

    pub async fn get_all_by_user_id(&self, user_id: &str) -> Result<Vec<WalletModel>> {
        let conn = self.conn.lock().await;
        let mut stmt =
            conn.prepare("SELECT * FROM wallet_table WHERE user_id = ?1 ORDER BY priority asc")?;
        let account_iter = stmt.query_map([user_id], |row| Ok(WalletModel::from_row(row)?))?;
        let accounts: Vec<WalletModel> = account_iter.collect::<Result<_>>()?;
        Ok(accounts)
    }

    pub async fn update(&self, wallet: &WalletModel) -> Result<Option<WalletModel>> {
        let conn = self.conn.lock().await;
        let rows_affected = conn.execute(
            "UPDATE wallet_table SET name = ?1, passphrase = ?2, public_key = ?3, imported = ?4, priority = ?5, status = ?6, type = ?7, create_time = ?8, modify_time = ?9, user_id = ?10, wallet_id = ?11, account_count = ?12, balance = ?13, fingerprint = ?14, show_wallet_recovery = ?15, migration_required = ?16 WHERE id = ?17",
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
                wallet.id
            ]
        )?;

        if rows_affected == 0 {
            return Err(rusqlite::Error::StatementChangedRows(0));
        }

        std::mem::drop(conn); // release connection before we want to use self.get()
        Ok(self.get(wallet.id).await?)
    }

    pub async fn delete(&self, id: u32) -> Result<()> {
        self.database.delete_by_id(id).await
    }

    pub async fn delete_by_wallet_id(&self, wallet_id: &str) -> Result<(), DatabaseError> {
        self.database
            .delete_by_column_id("wallet_id", wallet_id)
            .await
    }
}

#[cfg(test)]
mod tests {
    use crate::proton_wallet::db::dao::wallet_dao::WalletDao;
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
                    UNIQUE (wallet_id)
                )
                "#,
                [],
            );
        }
        let wallet_dao = WalletDao::new(conn_arc);
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

        let query_wallet = wallet_dao
            .get_default_wallet_by_user_id("user123")
            .await
            .unwrap()
            .unwrap();
        assert_eq!(query_wallet.name, "MyWallet");
        assert_eq!(query_wallet.passphrase, 0);
        assert_eq!(query_wallet.account_count, 3);
        assert_eq!(query_wallet.balance, 150.75);

        let wallets = wallet_dao.get_all().await.unwrap();
        assert_eq!(wallets.len(), 1);

        // test update
        result.balance = 199.0;
        result.account_count = 4;
        result.name = "Hello world".to_string();
        let result_update = wallet_dao.upsert(&result).await.unwrap().unwrap();
        assert_eq!(result_update.name, "Hello world");
        assert_eq!(result_update.passphrase, 0);
        assert_eq!(result_update.account_count, 4);
        assert_eq!(result_update.balance, 199.0);
    }
}
